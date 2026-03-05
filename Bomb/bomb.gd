extends Sprite2D

class_name Bomb

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var verticalRay : RayCast2D = $RayCast2D
@onready var horizontalRay : RayCast2D = $RayCast2D2

@export var radius : int

	
func activate_bomb() -> void:
	animationPlayer.play("bomb_detonation")

func activate_explosion() -> void:
	frame_changed()
	queue_free()

func frame_changed():
	FrameDirtyNotifier.emit_signal("frame_dirty")
