extends Sprite2D

class_name Bomb

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var verticalRay : RayCast2D = $RayCast2D
@onready var horizontalRay : RayCast2D = $RayCast2D2

@export var radius : int

func activate_bomb() -> void:
	animationPlayer.play("bomb_detonation")

func activate_explosion() -> void:
	var mainLevel : MainLevel = get_parent() as MainLevel
	mainLevel.destroyTiles(global_position,radius)
	queue_free()
