extends BaseMenu

@onready var winner_label: Label = $WinnerLabel
@onready var winner_sprite: Sprite2D = $WinnerSprite

func _ready() -> void:
	parent_scene = "res://Scenes/MainMenu/MainMenu.tscn"
	super._ready()
	
	if SelectionManager.winner_player_id > 0:
		winner_label.text = "PLAYER " + str(SelectionManager.winner_player_id) + "\nWINS!"
		if SelectionManager.winner_sprite:
			winner_sprite.texture = SelectionManager.winner_sprite
	else:
		winner_label.text = "WINNER!"

func execute_button(button_name: String) -> void:
	match button_name:
		"ReplayButton":
			get_tree().change_scene_to_file("res://Scenes/SelectionMenu/SelectionMenu.tscn")
		"MainMenuButton":
			get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
