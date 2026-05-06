extends BaseMenu

var menu_scenes = {
	"PlayButton": "res://Scenes/SelectionMenu/SelectionMenu.tscn",
	"SetupButton": "res://Scenes/SetupMenu/SetupMenu.tscn",
	"SettingsButton": "res://Scenes/SettingsMenu/SettingsMenu.tscn"
}

func execute_button(button_name: String) -> void:
	if button_name in menu_scenes:
		var scene_path = menu_scenes[button_name]
		get_tree().change_scene_to_file(scene_path)
