extends Node2D
class_name PowerUp

@export var sprite_texture: Texture2D
@export var spawn_position: Vector2 = Vector2.ZERO
@export var pickup_distance: float = 2.0  # Distance to pickup

var player_group = "players"

func _ready() -> void:
	var sprite = Sprite2D.new()
	sprite.texture = sprite_texture
	sprite.centered = true
	add_child(sprite)
	
	global_position = spawn_position
	
	# Add to a group to identify as powerup (so bombs don't destroy it)
	add_to_group("powerups")


func _physics_process(_delta: float) -> void:
	for player in get_tree().get_nodes_in_group(player_group):
		if global_position.distance_to(player.global_position) < pickup_distance:
			apply(player)
			queue_free()
			return


func apply(_player: Node) -> void:
	# Override in subclasses
	pass
