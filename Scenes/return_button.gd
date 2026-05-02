extends Button

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("p1_bomb") or event.is_action_pressed("p2_bomb")) and has_focus():
		return_to_main_menu()

func return_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
