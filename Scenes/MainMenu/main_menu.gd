extends BaseMenu

@onready var quit_confirm_label: Label = $QuitConfirmLabel
@onready var quit_overlay: ColorRect = $QuitOverlay

var menu_scenes = {
	"PlayButton": "res://Scenes/SelectionMenu/SelectionMenu.tscn",
	"SetupButton": "res://Scenes/SetupMenu/SetupMenu.tscn",
}

var quit_confirm_pending: bool = false

func _ready() -> void:
	parent_scene = ""  # MainMenu is the entry point, no parent
	super._ready()
	SoundManager.play_music("menu")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		if quit_confirm_pending:
			_quit_game()
		else:
			quit_confirm_pending = true
			quit_confirm_label.visible = true
			quit_overlay.visible = true
		return

	if quit_confirm_pending and event is InputEventKey and event.pressed:
		quit_confirm_pending = false
		quit_confirm_label.visible = false
		quit_overlay.visible = false

	super._input(event)

func execute_button(button_name: String) -> void:
	if button_name in menu_scenes:
		var scene_path = menu_scenes[button_name]
		_change_scene_with_led_sync(scene_path)

func _quit_game() -> void:
	if has_node("/root/LedMatrixManager"):
		var led_manager = get_node("/root/LedMatrixManager")
		led_manager.stop_syncing()
		led_manager.serial.close()
	get_tree().quit()
