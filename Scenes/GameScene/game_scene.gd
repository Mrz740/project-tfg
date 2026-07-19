extends Node2D

@onready var health_counter_scene: PackedScene = preload("res://Managers/HealthCounter/health_counter.tscn")
@onready var hbox_container: HBoxContainer = $ColorRect/HBoxContainer

@export var powerup_spawn_interval: float = 5.0  # Spawn a powerup every 5 seconds

var powerup_types: Array[String] = ["heal", "big_bomb", "shield"]
var spawn_timer: Timer
var player1_spawn_point: Vector2 = Vector2(2, 62)
var player2_spawn_point: Vector2 = Vector2(62, 10)

func _ready():
	Player._round_ending = false
	TileManager.background_tilemap = $BackgroundTile
	TileManager.destructible_tilemap = $DestructibleTile

	# Get players and apply selected sprites
	var players = get_tree().get_nodes_in_group("players")
	for i in range(players.size()):
		if i < 2:  # Only apply for first 2 players
			players[i].texture = SelectionManager.get_player_sprite(i)
	
	# Create health counters for each player
	for player in players:
		var health_counter: HealthCounter = health_counter_scene.instantiate()
		hbox_container.add_child(health_counter)
		health_counter.initialize(player.max_hp, player.texture)
		player.health_counter = health_counter
	
	# Setup powerup spawn timer
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = powerup_spawn_interval
	spawn_timer.timeout.connect(_on_powerup_spawn_timer_timeout)
	spawn_timer.start()


func _on_spawn_tile_timer_timeout():
	#TileManager.spawn_tile(Vector2(10,10),Vector2(1,0))
	pass

func spawn_powerup(powerup_type: String, spawn_pos: Vector2) -> void:
	var powerup: PowerUp
	
	match powerup_type:
		"heal":
			powerup = HealPowerUp.new()
		"big_bomb":
			powerup = BigBombPowerUp.new()
		"shield":
			powerup = ShieldPowerUp.new()
		_:
			return
	
	powerup.spawn_position = spawn_pos
	add_child(powerup)


func _on_powerup_spawn_timer_timeout() -> void:
	var spawn_pos = get_random_spawn_position()
	if spawn_pos != Vector2.ZERO:
		var random_type = powerup_types[randi() % powerup_types.size()]
		spawn_powerup(random_type, spawn_pos)


func get_random_spawn_position() -> Vector2:
	var tilemap = TileManager.destructible_tilemap
	var used_cells = tilemap.get_used_cells()
	
	if used_cells.is_empty():
		return Vector2.ZERO
	
	# Try to find a free position in the playable area
	for _attempt in range(50):  # Try up to 50 times
		var random_cell = used_cells[randi() % used_cells.size()]
		var world_pos = TileManager.tile_to_world(random_cell) + Vector2(2, 2)
		
		# Check if the position is free (not occupied by tiles)
		if not TileManager.is_tile_free(world_pos):
			continue
		
		# Check if position is occupied by grid entities (players, bombs, turrets)
		var occupied = false
		for entity in get_tree().get_nodes_in_group("grid_entities"):
			if world_pos.distance_to(entity.global_position) < TileManager.tile_size:
				occupied = true
				break
		
		if occupied:
			continue
		
		# Check if position is occupied by other powerups
		for powerup in get_tree().get_nodes_in_group("powerups"):
			if world_pos.distance_to(powerup.global_position) < TileManager.tile_size:
				occupied = true
				break
		
		if occupied:
			continue
		
		return world_pos
	
	return Vector2.ZERO  # Return zero if no free position found

