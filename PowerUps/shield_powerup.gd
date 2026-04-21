extends PowerUp
class_name ShieldPowerUp

func _ready() -> void:
	sprite_texture = preload("res://PowerUps/shield_powerup.png") if ResourceLoader.exists("res://PowerUps/shield_powerup.png") else null
	super()

func apply(player: Node) -> void:
	if player.has_method("apply_shield"):
		player.apply_shield()
