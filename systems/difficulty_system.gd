extends Node


@export var mob_spawner: MobSpawner
@export var initial_spawn_rate_per_minute:float = 60.0
@export var spawn_rate_per_minute: float = 30
@export var wave_duration: float = 20.0
@export var break_intensity = 0.5

var time: float = 0.0

func _process(delta: float) -> void:
	# Ignorar Game Over
	if GameManager.is_game_over: return
	
	time += delta
	
	# Dificuldade linear - Linha verde
	var spawn_rate: float = initial_spawn_rate_per_minute + (spawn_rate_per_minute * time/60)
	
	# Sistema de ondas (Linha rosa)
	var sin_wave = sin((time * TAU) / wave_duration) #PI = 3.1417   2PI = TAU
	var wave_factor = remap(sin_wave,-1.0, 1.0, break_intensity, 1)
	
	spawn_rate *= wave_factor
	#print("Time: %.2f, Wave_Factor: %.2f, Spawn Rate: %.2f" % [time, wave_factor, spawn_rate])
	mob_spawner.mobs_per_minute = spawn_rate
