extends Node

const W = 64
const H = 64

var serial := GdSerial.new()
var last_frame := PackedByteArray()
var syncing := false

func _ready():
	pass

func connect_led(port: String, baud_rate: int) -> void:
	serial.set_port(port)
	serial.set_baud_rate(baud_rate)
	serial.open()
	call_deferred("_initialize")

func _initialize() -> void:
	await get_tree().process_frame
	last_frame = PackedByteArray()
	serial.write([255, 255, 0, 0, 0])

func start_syncing() -> void:
	syncing = true

func stop_syncing() -> void:
	syncing = false

func _process(_delta):
	if not syncing or not serial.is_open():
		return
	
	var viewport = get_viewport()
	if not viewport:
		return
	
	var img = viewport.get_texture().get_image()
	img.resize(W, H)
	img.convert(Image.FORMAT_RGB8)

	var data: PackedByteArray = img.get_data()

	if last_frame.size() != data.size():
		last_frame = data.duplicate()
		return

	for i in range(0, data.size(), 3):
		var r = data[i]
		var g = data[i + 1]
		var b = data[i + 2]

		var lr = last_frame[i]
		var lg = last_frame[i + 1]
		var lb = last_frame[i + 2]

		if r != lr or g != lg or b != lb:
			var pixel_index = i / 3
			var x = int(pixel_index % W)
			var y = int(pixel_index / W)

			serial.write([x])
			serial.write([y])
			serial.write([r])
			serial.write([g])
			serial.write([b])

	last_frame = data.duplicate()

func _exit_tree():
	if syncing:
		serial.write([255, 255, 0, 0, 0])
