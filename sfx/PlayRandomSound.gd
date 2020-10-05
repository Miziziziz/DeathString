extends Node2D


func play():
	for child in get_children():
		child.stop()
	get_child(randi() % get_child_count()).play()
