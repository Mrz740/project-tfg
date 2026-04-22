extends Control

class_name HealthCounter

func initialize(hp: int, player_texture: Texture2D = null) -> void:
	var playerIcon = $PlayerIcon
	playerIcon.texture = player_texture 
	var hbox = $HBoxContainer
	for i in range(hp):
		var color_rect = ColorRect.new()
		color_rect.custom_minimum_size = Vector2(2, 2)
		color_rect.color = Color.WHITE
		hbox.add_child(color_rect)

func remove_hp() -> void:
	var hbox = $HBoxContainer
	if hbox.get_child_count() > 0:
		hbox.get_child(hbox.get_child_count() - 1).queue_free()

func clear_display() -> void:
	var hbox = $HBoxContainer
	for child in hbox.get_children():
		child.queue_free()