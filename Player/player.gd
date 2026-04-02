extends GridEntity
class_name Player

const UP := Vector2(0,-1)
const DOWN := Vector2(0,1)
const LEFT := Vector2(-1,0)
const RIGHT := Vector2(1,0)

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
	bombInst.activate_bomb()
	bomb_ready = false
	bombTimer.start(bomb_cooldown)

func _on_timer_timeout() -> void:
	bomb_ready = true

func take_damage(damage: int) -> void:
	if invincible:
		return

	current_hp -= damage
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
	visible = false
	remove_from_group("players")
