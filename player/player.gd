class_name Player
extends CharacterBody2D

signal meat_collected(value: int)

@export_category("Movement")
@export var speed: float = 3.0

@export_category("Attack")
@export var sword_damage: int = 2

@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30.0
@export var ritual_scene: PackedScene

@export_category("Health")
@export var health: int = 100
@export var max_health: int = 100

@export_category("Mana")
@export var mana: float = 100.0
@export var max_mana: int = 100
@export var mana_regen_factor: float = 0.05

@export_category("Prefab")
@export var death_prefab: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar
@onready var mana_progress_bar: ProgressBar = $ManaProgressBar

var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0


func _ready():
	GameManager.player = self
	meat_collected.connect(func(): 
		GameManager.meat_counter += 1
	)


func _process(delta):
	GameManager.player_position = position
	
	# Read input
	read_input()
	
	# Process attack
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
	
	if Input.is_action_just_pressed("special"):
		special()
	
	# Process animation and sprite rotation
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
	
	# Process damage
	update_hitbox_detection(delta)
	
	# Update health bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

	# Update mana bar
	regen_mana_over_time()
	mana_progress_bar.max_value = max_mana
	mana_progress_bar.value = mana
	print(mana)


func _physics_process(delta):
	# Modify velocity
	var target_velocity = input_vector * speed * 100
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()


func update_attack_cooldown(delta: float):
	# Update attack cooldown
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")


func update_ritual(delta: float):
	# Update cooldown
	ritual_cooldown -= delta
	if ritual_cooldown > 0:
		return
	ritual_cooldown = ritual_interval
	
	# Create ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)


func read_input():
	# Obtain input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Remove deadzone from input_vector
	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0.0
		
	# Update is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()


func play_run_idle_animation():
		# Play animations
	if not is_attacking and was_running != is_running:
		if is_running:
			animation_player.play("run")
		else:
			animation_player.play("idle")


func rotate_sprite():
	# flip sprite
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true


func attack():
	if is_attacking:
		return
		
	# Play animation
	animation_player.play("attack_side_1" if randi() % 2 == 0 else "attack_side_2")
	
	# Cooldown attack
	attack_cooldown = 0.6
	
	# Set attack to true
	is_attacking = true


func special():
	var special_cost = 25
	if mana < special_cost:
		return
	
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	mana -= special_cost
	add_child(ritual)


func deal_damage():
	# var enemies = get_tree().get_nodes_in_group("enemies")
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.3:
				enemy.damage(sword_damage)


func update_hitbox_detection(delta: float):
	# Timer
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0:
		return
	
	# Frequency
	hitbox_cooldown = 0.5
	
	# Detect enemies
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var damage_amount = 1
			damage(damage_amount)


func damage(amount: int):
	if health <= 0:
		return
	
	health -= amount
	
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	if health <= 0:
		die()


func die():
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	queue_free()


func heal(amount: int):
	health += amount
	if health > max_health:
		health = max_health

	return health


func regen_mana_over_time():
	if(mana < max_mana):
		mana += mana_regen_factor
	
	if(mana > max_mana):
		mana = max_mana
