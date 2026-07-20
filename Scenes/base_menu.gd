extends Node2D
class_name BaseMenu

var vbox: Node = null
var buttons: Array[Button] = []
var current_index: int = 0
var parent_scene: String = ""  # Scene to return to when pressing "return"

func _ready() -> void:
	vbox = get_node_or_null("VBoxContainer")
	if vbox == null:
		return
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
	if event.is_action_pressed("return"):
		if parent_scene != "":
			SoundManager.play_sfx("menu_select")
			_change_scene_with_led_sync(parent_scene)
		return
	
	# Consume arrow keys to prevent default focus behavior
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT:
				get_tree().root.set_input_as_handled()
	
	if buttons.is_empty():
		return
	if event.is_action_pressed("p1_up") or event.is_action_pressed("p2_up"):
		current_index = wrapi(current_index - 1, 0, buttons.size())
		buttons[current_index].grab_focus()
		SoundManager.play_sfx("menu_move")
	elif event.is_action_pressed("p1_down") or event.is_action_pressed("p2_down"):
		current_index = wrapi(current_index + 1, 0, buttons.size())
		buttons[current_index].grab_focus()
		SoundManager.play_sfx("menu_move")
	elif event.is_action_pressed("p1_bomb") or event.is_action_pressed("p2_bomb"):
		SoundManager.play_sfx("menu_select")
		execute_button(buttons[current_index].name)

func execute_button(_button_name: String) -> void:
	pass

func _change_scene_with_led_sync(scene_path: String) -> void:
	"""Change scene. The LED matrix's frame diffing keeps running across
	the scene change (LedMatrixManager is an autoload, unaffected by the
	scene swap), so it naturally sends only the pixels that actually
	differ between the old and new scene instead of a forced full resend."""
	get_tree().change_scene_to_file(scene_path)
