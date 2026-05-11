extends Node

# Sprite mapping - frame index to sprite path
const SPRITE_PATHS: Array[String] = [
	"res://Player/PlayerSprites/player_sprite1.png",
	"res://Player/PlayerSprites/player_sprite2.png",
	"res://Player/PlayerSprites/player_sprite3.png",
	"res://Player/PlayerSprites/player_sprite4.png"
]

# Store selected frames for each player
var player1_selected_frame: int = 0
var player2_selected_frame: int = 0

func get_player_sprite(player: int) -> Texture2D:
	var frame = player1_selected_frame if player == 0 else player2_selected_frame
	return load(SPRITE_PATHS[frame])

func set_selections(p1_frame: int, p2_frame: int) -> void:
	player1_selected_frame = p1_frame
	player2_selected_frame = p2_frame
