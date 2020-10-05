extends Node2D


func _ready():
	for child in $Graphics.get_children():
		child.hide()
	var i = randi() % $Graphics.get_child_count()
	var sprite : Sprite = $Graphics.get_child(i)
	sprite.show()
	sprite.rotation = (randi() % 4) * PI / 2
