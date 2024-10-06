extends Sprite2D

@export var loot: Node


func drop_item():
	if(loot):
		get_parent().add_child(loot)
