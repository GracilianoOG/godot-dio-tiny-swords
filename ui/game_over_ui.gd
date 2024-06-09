class_name GameOverUI
extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var monsters_label: Label = %MonstersLabel


func _ready():
	time_label.text = GameManager.time_elapsed_string
	monsters_label.text = str(GameManager.monsters_defeated_counter)


func _on_menu_pressed():
	get_tree().change_scene_to_file("res://ui/game_menu.tscn")


func _on_restart_pressed():
	GameManager.reset()
	get_tree().reload_current_scene()
