extends StaticBody2D

func _ready():
	$Sprite2D.flip_h = randi() % 2 == 0
