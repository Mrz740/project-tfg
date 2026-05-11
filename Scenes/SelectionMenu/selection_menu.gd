extends Node2D

const SPRITE_FRAMES: int = 4
const COUNTDOWN_TIME: float = 5.0

# Player data structure
class PlayerState:
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
@onready var cooldown_pixels: Array[ColorRect] = [
	$Pixel1,
	$Pixel2,
	$Pixel3,
	$Pixel4,
	$Pixel5
]

var pixels_active: int = 0
var conflict_warning_shown: bool = false

func _ready() -> void:
	players[0].selected_frame = 0
	players[1].selected_frame = 1
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

func _toggle_lock(player: int) -> void:
	players[player].locked = !players[player].locked
	player_locks[player].visible = players[player].locked
	
	# If unlocking, reset cooldown
	if not players[player].locked:
		if timer.is_stopped() == false:
			timer.stop()
		pixels_active = 0
		_update_cooldown_display()
	
	_check_both_locked()

func _update_displays() -> void:
	for i in range(2):
		var player_data = players[i]
		player_sprites[i].frame = player_data.selected_frame
		player_locks[i].frame = player_data.selected_frame

func _check_conflict() -> void:
	conflict_sprite.visible = players[0].selected_frame == players[1].selected_frame
	conflict_warning_shown = conflict_sprite.visible

func _check_both_locked() -> void:
	if players[0].locked and players[1].locked and not conflict_warning_shown:
		_start_cooldown()

# Start cooldown timer
func _start_cooldown() -> void:
	pixels_active = cooldown_pixels.size()
	_update_cooldown_display()
	timer.start(COUNTDOWN_TIME / cooldown_pixels.size())  # Divide cooldown evenly

func _on_timer_timeout() -> void:
	if pixels_active > 0:
		pixels_active -= 1
		_update_cooldown_display()
		if pixels_active == 0:
			timer.stop()
			_transition_to_map_selection()

func _update_cooldown_display() -> void:
	for i in range(cooldown_pixels.size()):
		cooldown_pixels[i].visible = i < pixels_active

func _transition_to_map_selection() -> void:
	get_tree().change_scene_to_file("res://Scenes/SelectionMenu/MapSelectionMenu.tscn")
