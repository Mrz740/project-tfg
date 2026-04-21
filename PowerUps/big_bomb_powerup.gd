extends PowerUp
class_name BigBombPowerUp

func _ready() -> void:
	sprite_texture = preload("res://PowerUps/big_bomb_powerup.png") if ResourceLoader.exists("res://PowerUps/big_bomb_powerup.png") else null
	super()

func apply(player: Node) -> void:
	player.has_big_bomb = true
