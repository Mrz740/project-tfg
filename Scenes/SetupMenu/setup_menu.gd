extends BaseMenu

@export var led_baud_rate: int = 2000000

@onready var connection_state_label: Label = %ConnectionStateLabel
@onready var button_theme: Theme = preload("res://Scenes/button_theme.tres")

var matrix_connected: bool = false
var available_ports: Dictionary = {}
var port_buttons: Array[Button] = []

func _ready() -> void:
	for child in vbox.get_children():
		if child is Button:
			buttons.append(child)
			child.focus_mode = Control.FOCUS_ALL
	await get_tree().process_frame
	if buttons.size() > 0:
		buttons[0].grab_focus()

func execute_button(button_name: String) -> void:
	match button_name:
		"ReturnButton":
			return_to_main()
		"ScanButton":
			scan_ports()
		_:
			# Port button pressed - extract port name
			if button_name.begins_with("Port_"):
				var port_name = button_name.trim_prefix("Port_")
				connect_to_port(port_name)

func return_to_main() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func scan_ports() -> void:
	available_ports = LedMatrixManager.get_open_ports()
	create_port_buttons()

func create_port_buttons() -> void:
	for btn in port_buttons:
		btn.queue_free()
	port_buttons.clear()
	
	buttons = buttons.filter(func(btn): return btn.name == "ReturnButton" or btn.name == "ScanButton")
	current_index = 0
	
	for port_data in available_ports.values():
		var port_name = port_data.get("port_name", "Unknown") if port_data is Dictionary else str(port_data)
		var port_button = Button.new()
		port_button.name = "Port_" + port_name
		port_button.text = port_name
		port_button.theme = button_theme
		port_button.focus_mode = Control.FOCUS_ALL
		vbox.add_child(port_button)
		port_buttons.append(port_button)
		buttons.append(port_button)
	
	if buttons.size() > 0:
		buttons[1].grab_focus()
		current_index = 1

func connect_to_port(port: String) -> void:
	LedMatrixManager.stop_syncing()
	
	matrix_connected = LedMatrixManager.try_connect_led(port, led_baud_rate)
	if matrix_connected:
		connection_state_label.text = "CONNECTED"
		connection_state_label.modulate = Color(0, 1, 0)
		LedMatrixManager.start_syncing()
	else:
		connection_state_label.text = "ERROR"
		connection_state_label.modulate = Color(1, 0, 0)
