extends Node2D

@export var regeneration_amount: int = 10

# @onready var area2d: Area2D = $Area2D
# The code above is the same as the _ready func below

var area2d: Area2D


func _ready():
	area2d = $Area2D
	area2d.body_entered.connect(on_body_entered)


func on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		var player: Player = body
		player.heal(regeneration_amount)
		player.meat_collected.emit()
		queue_free()
