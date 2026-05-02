extends Node2D
class_name BaseMenu

@onready var vbox = $VBoxContainer
var buttons: Array[Button]
var current_index: int = 0

func _ready() -> void:
	print("BaseMenu _ready() called")
	for child in vbox.get_children():
		print("Child: ", child.name, " is Button: ", child is Button)
		if child is Button:
			buttons.append(child)
			child.focus_mode = Control.FOCUS_ALL
	print("Total buttons found: ", buttons.size())
	await get_tree().process_frame
	if buttons.size() > 0:
		print("Grabbing focus on button: ", buttons[0].name)
		buttons[0].grab_focus()
	else:
		print("ERROR: No buttons found!")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_up") or event.is_action_pressed("p2_up"):
		print("UP pressed, current_index: ", current_index)
		current_index = (current_index - 1 + buttons.size()) % buttons.size()
		buttons[current_index].grab_focus()
	elif event.is_action_pressed("p1_down") or event.is_action_pressed("p2_down"):
		print("DOWN pressed, current_index: ", current_index)
		current_index = (current_index + 1) % buttons.size()
		buttons[current_index].grab_focus()
	elif event.is_action_pressed("p1_bomb") or event.is_action_pressed("p2_bomb"):
		print("SELECT pressed on button: ", buttons[current_index].name)
		execute_button(buttons[current_index].name)

func execute_button(_button_name: String) -> void:
	pass	
