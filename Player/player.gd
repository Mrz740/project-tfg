extends CharacterBody2D

const SPEED = 100

func _input(event):
	velocity = Vector2.ZERO
	if event.is_action_pressed("move_right"):
		velocity.x += 1
	if event.is_action_pressed("move_left"):
		velocity.x -= 1
	if event.is_action_pressed("move_down"):
		velocity.y += 1
	if event.is_action_pressed("move_up"):
		velocity.y -= 1
	position += velocity
