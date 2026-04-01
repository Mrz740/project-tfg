extends GridEntity
class_name Bomb

@export var radius: int = 2
@export var explode_time: float = 2.0
@export var flash_interval: float = 0.2

var direction: Vector2 = Vector2.ZERO
var flashing: bool = false
var elapsed: float = 0.0
var flash_timer: float = 0.0

@onready var explosion_scene: PackedScene = preload("res://Bomb/explosion.tscn")

func _ready():
	super()
	add_to_group("bombs")
	visible = true
	global_position = get_snapped_position(global_position)

func activate_bomb() -> void:
	visible = true
	flashing = true
	elapsed = 0.0
	flash_timer = 0.0

func push(dir: Vector2) -> void:
	direction = dir
	try_move(dir)
	
func _physics_process(delta: float) -> void:
	flashing_effect(delta)

	if elapsed >= explode_time:
		explode()

	if direction != Vector2.ZERO and not moving:
		if not try_move(direction):
			direction = Vector2.ZERO

	move_toward_target(delta)

func flashing_effect(delta: float) -> void:
	elapsed += delta
	flash_timer += delta

	var t = elapsed / explode_time
	flash_interval = 0.2 * pow(0.1, t)

	if flash_timer >= flash_interval:
		flash_timer = 0.0
		modulate = Color.RED if modulate == Color.WHITE else Color.WHITE
		
func explode() -> void:
	global_position = get_snapped_position(global_position)

	var explosion = explosion_scene.instantiate()
	get_parent().add_child(explosion)
	explosion.start(global_position, radius)

	queue_free()
