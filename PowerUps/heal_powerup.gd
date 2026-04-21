extends PowerUp
class_name HealPowerUp

func _ready() -> void:
	sprite_texture = preload("res://PowerUps/heal_powerup.png") if ResourceLoader.exists("res://PowerUps/heal_powerup.png") else null
	super()

func apply(player: Node) -> void:
	if player.has_method("heal"):
		player.heal(1)
