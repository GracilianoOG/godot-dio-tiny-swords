class_name GameOverUI
extends CanvasLayer

@export var restart_delay: float = 5.0

var restart_cooldown: float

@onready var time_label: Label = %TimeLabel
@onready var monsters_label: Label = %MonstersLabel


func _ready():
	time_label.text = GameManager.time_elapsed_string
	monsters_label.text = str(GameManager.monsters_defeated_counter)
	restart_cooldown = restart_delay


func _process(delta):
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart_game()


func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()


func _on_menu_pressed():
	get_tree().change_scene_to_file("res://ui/game_menu.tscn")


func _on_restart_pressed():
	restart_game()
