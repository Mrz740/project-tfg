extends GridEntity
class_name Player

const UP := Vector2(0,-1)
const DOWN := Vector2(0,1)
const LEFT := Vector2(-1,0)
const RIGHT := Vector2(1,0)
const BIG_BOMB_RADIUS := int(5)

@onready var bombTimer: Timer = $BombCooldown
@onready var bomb_scene: PackedScene = preload("res://Bomb/Bomb.tscn")

@export var player_id :int= 1
@export var max_hp :int= 3

var bomb_cooldown :float= 1.5
var bomb_ready: bool = true
var input_stack := []
var current_hp: int = max_hp

var invincible: bool = false
var invincibility_time: float = 1.0

var flash_elapsed: float = 0.0
var flash_timer: float = 0.0
var flashing: bool = false

var health_counter: HealthCounter

var has_shield: bool = false
var has_big_bomb: bool = false

static var _round_ending := false

func _init():
	current_hp = max_hp
	speed = 32

func _ready() -> void:
	super()
	bombTimer.start(bomb_cooldown)
	add_to_group("players")
	
func _physics_process(delta: float) -> void:
	var dir = Vector2.ZERO
	update_flashing(delta)
	if input_stack.size() > 0:
		dir = input_stack[input_stack.size() - 1][1]

	if dir != Vector2.ZERO:
		set_sprite_frame(dir) 
		try_move(dir)         

	move_toward_target(delta)

func set_sprite_frame(dir: Vector2) -> void:
	if dir == RIGHT:
		frame = 1
	elif dir == LEFT:
		frame = 0
	elif dir == DOWN:
		frame = 2
	elif dir == UP:
		frame = 3

func _input(event: InputEvent) -> void:
	var directions = {
		"p" + str(player_id) + "_right": RIGHT,
		"p" + str(player_id) + "_left": LEFT,
		"p" + str(player_id) + "_up": UP,
		"p" + str(player_id) + "_down": DOWN
	}

	for i in range(input_stack.size() - 1, -1, -1):
		if not Input.is_action_pressed(input_stack[i][0]):
			input_stack.remove_at(i)

	for action_name in directions.keys():
		if Input.is_action_just_pressed(action_name):
			input_stack.append([action_name, directions[action_name]])

	if event.is_action_pressed("p" + str(player_id) + "_bomb") and bomb_ready:
		drop_bomb()

func drop_bomb() -> void:
	var bombInst: Bomb = bomb_scene.instantiate()
	get_parent().add_child(bombInst)
	bombInst.global_position = get_snapped_position(global_position)
	
	if has_big_bomb:
		bombInst.radius = BIG_BOMB_RADIUS
		has_big_bomb = false
	else:
		bombInst.radius = 2
	
	bombInst.activate_bomb()
	bomb_ready = false
	bombTimer.start(bomb_cooldown)

func _on_timer_timeout() -> void:
	bomb_ready = true

func take_damage(damage: int) -> void:
	if has_shield:
		has_shield = false
		modulate = Color.WHITE
		return
	
	if invincible:
		return

	current_hp -= damage
	if health_counter:
		health_counter.remove_hp()
	
	if current_hp <= 0:
		die()
		return
	invincible = true

	flash_elapsed = 0.0
	flash_timer = 0.0
	flashing = true

	await get_tree().create_timer(invincibility_time).timeout
	invincible = false

func update_flashing(delta: float) -> void:
	if not flashing:
		return

	flash_elapsed += delta
	flash_timer += delta

	var t = flash_elapsed / invincibility_time
	var interval = lerp(0.2, 0.02, pow(t, 2.0))

	if flash_timer >= interval:
		flash_timer = 0.0
		visible = !visible

	if flash_elapsed >= invincibility_time:
		flashing = false
		visible = true
		
func die() -> void:
	if _round_ending:
		return
	_round_ending = true

	visible = false
	remove_from_group("players")
	
	var all_players = get_tree().get_nodes_in_group("players")
	var winner_player: Player = null
	
	for player in all_players:
		if player != self:
			winner_player = player
			break
	
	if winner_player:
		SelectionManager.winner_player_id = winner_player.player_id
		SelectionManager.winner_sprite = winner_player.texture
		print("[Player] Player ", player_id, " died! Player ", winner_player.player_id, " wins!")
	else:
		print("[Player] Player ", player_id, " died! No winner found (draw?)")

	_change_scene_with_led_sync("res://Scenes/WinnerMenu/WinnerMenu.tscn")

func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)
	if health_counter:
		health_counter.clear_display()
		for i in range(current_hp):
			var color_rect = ColorRect.new()
			color_rect.custom_minimum_size = Vector2(2, 2)
			color_rect.color = Color.WHITE
			health_counter.get_node("HBoxContainer").add_child(color_rect)

func apply_shield() -> void:
	has_shield = true
	modulate = Color(0.0, 1.13, 18.892)  # Blue

func _change_scene_with_led_sync(scene_path: String) -> void:
	"""Change scene with LED sync to ensure all pixels are sent.
	Mirrors the same helper used in base_menu.gd / selection_menu.gd, since
	Player does not inherit from BaseMenu and can't reuse it directly."""
	if has_node("/root/LedMatrixManager"):
		var led_manager = get_node("/root/LedMatrixManager")
		if led_manager and led_manager.serial and led_manager.serial.is_open():
			print("[Player] LED connected - forcing full sync before scene change")
			led_manager.force_full_sync()
	get_tree().change_scene_to_file(scene_path)