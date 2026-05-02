extends BaseMenu

func execute_button(button_name: String) -> void:
	match button_name:
		"ReturnButton":
			return_to_main()

func return_to_main() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
