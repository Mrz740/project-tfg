extends Node

const W = 64
const H = 64

var serial := GdSerial.new()
var last_frame := PackedByteArray()
var syncing := false
# Evita que dos invocaciones de _process() se solapen mientras una está
# suspendida en el `await RenderingServer.frame_post_draw` (ver _process):
# sin esta guarda, dos ejecuciones podrían escribir por serie a la vez.
var _frame_busy := false

# =========================================================================
# INSTRUMENTACIÓN DE MÉTRICAS (añadido para el capítulo de Resultados)
# =========================================================================
# Controles:
#   F9  -> activa/desactiva la grabación de métricas (vuelca el CSV al
#          desactivar).
#   F10 -> cicla la etiqueta de escenario: reposo -> normal -> estres -> reposo
#          (cámbiala ANTES de pulsar F9, queda fija durante toda la sesión).
#
# Salida: user://metrics/sesion_<escenario>_<timestamp>.csv
# Columnas: frame_index, escenario, frame_duration_usec, pixels_changed,
#           bytes_sent, fps_instantaneo, game_frame_delta_usec, game_fps
#
#   frame_duration_usec / fps_instantaneo  -> SOLO el bucle de diffing +
#       envío por serie (lo que se transmite por LedMatrixManager).
#   game_frame_delta_usec / game_fps       -> el frame time completo del
#       juego (el "_delta" real recibido por _process en ESTE frame),
#       útil para comparar con el límite de max_fps=30 y ver si el cuello
#       de botella está en la transmisión o en el resto del bucle de juego.
#
# En Windows, user:// suele mapear a:
#   %APPDATA%\Godot\app_userdata\<NombreDelProyecto>\metrics\
# (el nombre exacto de carpeta es el "Application Name" en
# Project Settings > Application > Config).

var metrics_recording := false
var metrics_rows: Array = []
var metrics_scenario_options := ["reposo", "normal", "estres"]
var metrics_scenario_index := 0

func metrics_current_scenario() -> String:
	return metrics_scenario_options[metrics_scenario_index]

func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed:
		return

	if event.keycode == KEY_F10 and not metrics_recording:
		metrics_scenario_index = (metrics_scenario_index + 1) % metrics_scenario_options.size()
		print("[metrics] Escenario seleccionado: ", metrics_current_scenario())

	elif event.keycode == KEY_F9:
		if metrics_recording:
			_metrics_stop_and_dump()
		else:
			_metrics_start()

func _metrics_start() -> void:
	metrics_recording = true
	metrics_rows.clear()
	print("[metrics] Grabando métricas. Escenario: ", metrics_current_scenario(), " — pulsa F9 para parar y guardar.")

func _metrics_stop_and_dump() -> void:
	metrics_recording = false

	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("metrics"):
		dir.make_dir("metrics")

	var ts := Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var filename := "user://metrics/sesion_%s_%s.csv" % [metrics_current_scenario(), ts]

	var file := FileAccess.open(filename, FileAccess.WRITE)
	if file == null:
		push_error("[metrics] No se pudo abrir el archivo para escritura: " + filename)
		return

	file.store_line("frame_index,escenario,frame_duration_usec,pixels_changed,bytes_sent,fps_instantaneo,game_frame_delta_usec,game_fps")
	for row in metrics_rows:
		file.store_line("%d,%s,%d,%d,%d,%.2f,%d,%.2f" % [row.frame_index, row.escenario, row.duration_usec, row.pixels_changed, row.bytes_sent, row.fps, row.game_delta_usec, row.game_fps])
	file.close()

	print("[metrics] Guardado: ", filename, " (", metrics_rows.size(), " frames)")
	metrics_rows.clear()

# =========================================================================
# FIN BLOQUE DE INSTRUMENTACIÓN — el resto es la lógica original del manager
# (ya con el fix del buffer "todo negro" en start_syncing/force_full_sync)
# =========================================================================

func _ready():
	pass

func try_connect_led(port: String, baud_rate: int) -> bool:
	if serial.is_open():
		serial.close()
	serial.set_port(port)
	serial.set_baud_rate(baud_rate)
	var connected :bool = serial.open()
	return connected

func start_syncing() -> void:
	await get_tree().process_frame
	# Empezamos con un buffer "todo negro" en vez de uno vacío, así el
	# primer frame real se compara contra negro y se envía completo,
	# en lugar de adoptarse silenciosamente como línea base sin transmitir
	# nada (ver nota en force_full_sync más abajo).
	last_frame = PackedByteArray()
	last_frame.resize(W * H * 3)
	serial.write([255, 255, 0, 0, 0])
	syncing = true

func stop_syncing() -> void:
	syncing = false
	clear_display()

func force_full_sync() -> void:
	"""Force a full frame sync: sends a real clearScreen command to the
	ESP32 (so the physical panel actually goes blank) AND resets the local
	diffing buffer to an explicit all-black frame (not an empty array).

	Why all-black and not empty: _process() treats an EMPTY last_frame as
	"no baseline yet" and silently adopts whatever is on screen at that
	moment as the new baseline, WITHOUT sending it over serial (see the
	`if last_frame.is_empty(): ... return` guard in _process). Since
	change_scene_to_file() is deferred (not instant), that very first
	_process() call after a scene change can already be looking at the
	FULLY-RENDERED new menu — meaning the entire new menu gets silently
	swallowed as "baseline" and never actually transmitted, which is
	exactly the bug where only pixels that change afterwards (e.g. button
	focus highlight) show up on the panel.

	Using an explicit all-black buffer instead of an empty one means the
	diffing loop always runs as a real comparison from the very first
	frame, so the complete new menu is correctly detected as "changed from
	black" and sent in full."""
	print("[LED] Force full sync - clearing physical panel and frame buffer")
	if serial.is_open():
		serial.write([255, 255, 0, 0, 0])
	last_frame = PackedByteArray()
	last_frame.resize(W * H * 3)

func clear_display() -> void:
	if serial.is_open():
		serial.write([255, 255, 0, 0, 0])

func _process(delta):
	if not syncing or not serial.is_open():
		return

	# Si la invocación anterior de _process() todavía está suspendida en el
	# await de abajo (p. ej. por un frame lento o render en hilo aparte),
	# no arrancamos una segunda en paralelo: ambas escribiendo por el mismo
	# puerto serie a la vez podría desalinear el protocolo de 5 bytes/píxel
	# que lee el firmware (sin framing ni resync).
	if _frame_busy:
		return
	_frame_busy = true

	await RenderingServer.frame_post_draw

	# --- inicio de medición de este frame ---
	var t_start := Time.get_ticks_usec()
	var pixels_changed := 0
	var bytes_sent := 0
	var game_delta_usec := int(delta * 1000000.0)
	# -----------------------------------------

	var img = get_viewport().get_texture().get_image()

	if img.is_empty():
		_frame_busy = false
		return

	img.resize(W, H, Image.INTERPOLATE_NEAREST)
	img.convert(Image.FORMAT_RGB8)

	var data: PackedByteArray = img.get_data()

	if last_frame.is_empty():
		last_frame = data.duplicate()
		_frame_busy = false
		return

	for i in range(0, data.size(), 3):
		var rgb = (data[i] << 16) | (data[i + 1] << 8) | data[i + 2]
		var last_rgb = (last_frame[i] << 16) | (last_frame[i + 1] << 8) | last_frame[i + 2]

		if rgb != last_rgb:
			var r = (rgb >> 16) & 0xFF
			var g = (rgb >> 8) & 0xFF
			var b = rgb & 0xFF

			var pixel_index = i / 3
			var x = int(pixel_index % W)
			var y = int(pixel_index / W)

			serial.write([x])
			serial.write([y])
			serial.write([r])
			serial.write([g])
			serial.write([b])

			# --- contabilizar para métricas ---
			pixels_changed += 1
			bytes_sent += 5
			# -----------------------------------

	last_frame = data.duplicate()

	# --- fin de medición de este frame, registrar fila ---
	if metrics_recording:
		var t_end := Time.get_ticks_usec()
		var duration_usec := t_end - t_start
		var fps_instantaneo := 0.0
		if duration_usec > 0:
			fps_instantaneo = 1000000.0 / float(duration_usec)
		var game_fps := 0.0
		if game_delta_usec > 0:
			game_fps = 1000000.0 / float(game_delta_usec)
		metrics_rows.append({
			"frame_index": metrics_rows.size(),
			"escenario": metrics_current_scenario(),
			"duration_usec": duration_usec,
			"pixels_changed": pixels_changed,
			"bytes_sent": bytes_sent,
			"fps": fps_instantaneo,
			"game_delta_usec": game_delta_usec,
			"game_fps": game_fps,
		})
	# -------------------------------------------------------

	_frame_busy = false

func get_open_ports() -> Dictionary:
	return serial.list_ports()

func _exit_tree():
	clear_display()