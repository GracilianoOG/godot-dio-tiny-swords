class_name Enemy
extends Node2D

@export_category("Enemy Health")
@export var health: int = 10
@export var death_prefab: PackedScene

@export_category("Enemy Damage")
@export var damage_caused: int = 5

@export_category("Drops")
@export var drop_chance: float = 0.1
@export var drop_items: Array[PackedScene]
@export var drop_chances: Array[float]

var damage_digit_prefab: PackedScene

@onready var damage_digit_marker = $DamageDigitMarker
@onready var follow_player = $FollowPlayer
@onready var MAX_SPEED = follow_player.speed


func _ready():
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")


func _process(_delta):
	reduce_speed_on_hit()


func reduce_speed_on_hit():
	var current_speed = follow_player.speed
	
	if current_speed < MAX_SPEED:
		current_speed += 0.02
		
		if current_speed > MAX_SPEED:
			current_speed = MAX_SPEED
	
	follow_player.speed = current_speed


func damage(amount: int):
	health -= amount
	follow_player.speed *= 0.2
	
	# Blink effect
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Create DamageDigit
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)
	
	# Process death
	if health <= 0:
		die()


func die():
	# Create skull
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		# Drop loot
		if randf() <= drop_chance:
			death_object.loot = choose_item_to_drop()
		get_parent().add_child(death_object)
	
	# Increase counter
	GameManager.monsters_defeated_counter += 1
	
	# Delete node
	queue_free()


func choose_item_to_drop():
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	return drop


func get_random_drop_item() -> PackedScene:
	# Lists with 1 item
	if drop_items.size() == 1:
		return drop_items[0]
	
	# Calculate max chance
	var max_chance: float = 0.0
	for chance in drop_chances:
		max_chance += chance
	
	# Throw dice
	var random_value = randf() * max_chance
	
	# Spin the wheel
	var needle: float = 0.0
	for i in drop_items.size():
		var item = drop_items[i]
		var chance = drop_chances[i] if i < drop_chances.size() else 1.0
		if random_value <= chance + needle:
			return item
		needle += chance
	
	return drop_items[0]
