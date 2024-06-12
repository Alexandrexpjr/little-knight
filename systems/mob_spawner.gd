class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene]
var mobs_per_minute: float = 60.0

@onready var path_follow_2d: PathFollow2D = %PathFollow2D
var cooldown: float = 0.0
var difficulty_cooldown: float = 15.0

func _process(delta:float) -> void:
	# Ignorar Game Over
	if GameManager.is_game_over: return
	
	# Atualiza posição
	var player_position = GameManager.player_position
	if player_position:
		global_position = player_position
	
	difficulty_cooldown -= delta
	if (difficulty_cooldown < 0):
		difficulty_cooldown = 15.0
		mobs_per_minute += 10.0
		print("Mobs por minuto: ", mobs_per_minute)
	
	cooldown -= delta
	if (cooldown > 0): return
	
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	# Checar se o ponto é válido
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b1000
	var result: Array = world_state.intersect_point(parameters, 1)
	
	if not result.is_empty(): return
	# Instanciar uma criatura aleatória
	var index = randi_range(0, creatures.size() - 1)
	var createre_scene = creatures[index]
	var creature = createre_scene.instantiate()
	#var point = get_point()
	creature.global_position = point
	get_parent().add_child(creature)

func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
