extends BaseMenu

@export var led_port: String = "COM4"
@export var led_baud_rate: int = 2000000

func execute_button(button_name: String) -> void:
	match button_name:
		"ReturnButton":
			return_to_main()
		"ConnectButton":
			connect_led()
		"StartSyncingButton":
			start_syncing()

func return_to_main() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func connect_led() -> void:
	LedMatrixManager.connect_led(led_port, led_baud_rate)

func start_syncing() -> void:
	LedMatrixManager.start_syncing()
