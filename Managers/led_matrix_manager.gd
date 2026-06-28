extends Node

const W = 64
const H = 64

var serial := GdSerial.new()
var last_frame := PackedByteArray()
var syncing := false

func _ready():
	pass

func try_connect_led(port: String, baud_rate: int) -> bool:
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

func _process(_delta):
	if not syncing or not serial.is_open():
		return

	await RenderingServer.frame_post_draw

	var img = get_viewport().get_texture().get_image()

	if img.is_empty():
		return
		
	img.resize(W, H, Image.INTERPOLATE_NEAREST)
	img.convert(Image.FORMAT_RGB8)

	var data: PackedByteArray = img.get_data()
	
	if last_frame.is_empty():
		last_frame = data.duplicate()
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

	last_frame = data.duplicate()

func get_open_ports() -> Dictionary:
	return serial.list_ports()
	
func _exit_tree():
	clear_display()