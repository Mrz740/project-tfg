extends Sprite2D

const UP :Vector2 = Vector2(0,-1)
const DOWN :Vector2 = Vector2(0,1)
const LEFT :Vector2 = Vector2(-1,0)
const RIGHT :Vector2 = Vector2(1,0)

@onready var bombTimer : Timer = $BombCooldown
@onready var bomb :Resource = preload("res://Bomb/Bomb.tscn")

var bomb_ready : bool = true
var velocity : Vector2

func _input(event: InputEvent) -> void: 
	velocity= Vector2.ZERO
	
	if event.is_action_pressed("move_right"):
		velocity = RIGHT
	if event.is_action_pressed("move_left"):
		velocity = LEFT
	if event.is_action_pressed("move_down"):
		velocity = DOWN
	if event.is_action_pressed("move_up"):
		velocity = UP
	if velocity != Vector2.ZERO:
		if check_collision(velocity):
			position += velocity
	
	if event.is_action_pressed("drop_bomb") and bomb_ready:
		drop_bomb()
		
func check_collision(target: Vector2) -> bool:
	var space_state :PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query :PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, global_position + target)
	
	query.exclude = [$"."]
	query.set_hit_from_inside(true)
	query.set_collide_with_areas(false)
	query.set_collide_with_bodies(true)

	var result :Dictionary = space_state.intersect_ray(query)

	if not result.is_empty():
		return false
	else:
		return true

func _on_timer_timeout() -> void:
	bomb_ready = true

func drop_bomb() -> void:
	var bombInst : Bomb = bomb.instantiate()
	get_parent().add_child(bombInst)
	bombInst.global_position = global_position
	bombInst.activate_bomb()
	bomb_ready = false
	bombTimer.start()
