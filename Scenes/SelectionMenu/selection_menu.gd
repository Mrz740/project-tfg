extends Node2D

const AVAILABLE_SPRITES: Array[String] = [
	"res://Player/PlayerSprites/player_sprite1.png",
	"res://Player/PlayerSprites/player_sprite2.png",
	"res://Player/PlayerSprites/player_sprite3.png"
]
const SPRITE_FRAMES: int = 4
const COOLDOWN_TIME: float = 3.0

# Player data structure
class PlayerState:
	var selected_sprite: int = 0
	var selected_frame: int = 0
	var locked: bool = false

var players: Array[PlayerState] = [PlayerState.new(), PlayerState.new()]

# Node references
@onready var player_sprites: Array[Sprite2D] = [
	$Background/Player1Container/Player1Sprite,
	$Background/Player2Container/Player2Sprite
]
@onready var player_locks: Array[Sprite2D] = [
	$Background/Player1Container/Player1Lock,
	$Background/Player2Container/Player2Lock
]
@onready var conflict_sprite: Sprite2D = $Background/ConflictSprite
@onready var timer: Timer = $Timer
@onready var cooldown_label: Label = $CooldownLabel

var remaining_time: float = 0.0

func _ready() -> void:
	players[0].selected_sprite = 0
	players[1].selected_sprite = 1
	_update_displays()
	_check_conflict()
	timer.timeout.connect(_on_timer_timeout)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
		return
	
	if event.is_action_pressed("p1_left"):
		_move_player(0, -1)
	elif event.is_action_pressed("p1_right"):
		_move_player(0, 1)
	elif event.is_action_pressed("p1_bomb"):
		_toggle_lock(0)
	
	if event.is_action_pressed("p2_left"):
		_move_player(1, -1)
	elif event.is_action_pressed("p2_right"):
		_move_player(1, 1)
	elif event.is_action_pressed("p2_bomb"):
		_toggle_lock(1)

# Generic player movement
func _move_player(player: int, direction: int) -> void:
	if players[player].locked:
		return
	players[player].selected_frame = wrapi(players[player].selected_frame + direction, 0, SPRITE_FRAMES)
	_update_displays()
	_check_conflict()

# Generic lock toggle
func _toggle_lock(player: int) -> void:
	players[player].locked = !players[player].locked
	player_locks[player].visible = players[player].locked
	_check_both_locked()

# Update all displays
func _update_displays() -> void:
	for i in range(2):
		var player_data = players[i]
		var sprite_path = AVAILABLE_SPRITES[player_data.selected_sprite]
		player_sprites[i].texture = load(sprite_path)
		player_sprites[i].frame = player_data.selected_frame
		player_locks[i].texture = load(sprite_path)
		player_locks[i].frame = player_data.selected_frame

# Conflict detection
func _check_conflict() -> void:
	var conflict: bool = (
		players[0].selected_sprite == players[1].selected_sprite and
		players[0].selected_frame == players[1].selected_frame
	)
	conflict_sprite.visible = conflict

# Check if both players are locked
func _check_both_locked() -> void:
	if players[0].locked and players[1].locked:
		_start_cooldown()

# Start cooldown timer
func _start_cooldown() -> void:
	remaining_time = COOLDOWN_TIME
	cooldown_label.text = str(int(ceil(remaining_time))) + "s"
	timer.start(0.1)

func _on_timer_timeout() -> void:
	remaining_time -= 0.1
	cooldown_label.text = str(int(ceil(remaining_time))) + "s"
	
	if remaining_time <= 0.0:
		timer.stop()
		cooldown_label.text = ""
		_transition_to_map_selection()

func _transition_to_map_selection() -> void:
	get_tree().change_scene_to_file("res://Scenes/SelectionMenu/MapSelectionMenu.tscn")
