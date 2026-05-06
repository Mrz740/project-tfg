extends Node2D
class_name BaseMenu

@onready var vbox = $VBoxContainer
var buttons: Array[Button] = []
var current_index: int = 0

func _ready() -> void:
	for child in vbox.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if child is Button:
			buttons.append(child)
			child.focus_mode = Control.FOCUS_ALL
	await get_tree().process_frame
	if buttons.is_empty():
		return
	buttons[0].grab_focus()

func _input(event: InputEvent) -> void:
	if buttons.is_empty():
		return
	if event.is_action_pressed("p1_up"):
		current_index = wrapi(current_index - 1, 0, buttons.size())
		buttons[current_index].grab_focus()
	elif event.is_action_pressed("p1_down"):
		current_index = wrapi(current_index + 1, 0, buttons.size())
		buttons[current_index].grab_focus()
	elif event.is_action_pressed("p1_bomb"):
		execute_button(buttons[current_index].name)

func execute_button(_button_name: String) -> void:
	pass
