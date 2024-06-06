extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
# @onready var gold_label: Label = %GoldLabel
@onready var skull_label: Label = %SkullLabel


func _process(delta: float):
	# Update labels
	timer_label.text = GameManager.time_elapsed_string
	skull_label.text = str(GameManager.monsters_defeated_counter)
