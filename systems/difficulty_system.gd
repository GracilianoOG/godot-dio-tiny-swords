extends Node


@export var mob_spawner: MobSpawner
@export var initial_spawn_rate: float = 60.0
@export var mob_spawn_rate: float = 30.0
@export var wave_duration: float = 20.0
@export var wave_intensity: float = 0.5


var time: float = 0.0


func _process(delta):
	# Ignore game over
	if GameManager.is_game_over: return
	
	# Increment timer
	time += delta
	
	# Linear difficulty
	var spawn_rate = initial_spawn_rate + mob_spawn_rate * (time / 60.0)
	
	# Wave system
	var sin_wave = sin((time * TAU) / wave_duration)
	var wave_factor = remap(sin_wave, -1.0, 1.0, wave_intensity, 1.0)
	spawn_rate *= wave_factor
	
	# Apply difficulty
	mob_spawner.spawn_rate = spawn_rate
	# print("Time: %.2f, Wave: %.2f" % [time, sin_wave])
