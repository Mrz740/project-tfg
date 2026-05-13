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
	last_frame = get_viewport().get_texture().get_image().get_data()
	serial.write([255, 255, 0, 0, 0])
	syncing = true

func stop_syncing() -> void:
	syncing = false
	clear_display()

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
