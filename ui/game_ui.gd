extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
# @onready var gold_label: Label = %GoldLabel
@onready var meat_label: Label = %MeatLabel


func _process(delta: float):
	# Update labels
	timer_label.text = GameManager.time_elapsed_string
	meat_label.text = str(GameManager.monsters_defeated_counter)
