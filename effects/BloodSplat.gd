extends Node2D

export var play_death_sound = true

func _ready():
	for child in $Graphics.get_children():
		child.hide()
	var i = randi() % $Graphics.get_child_count()
	var sprite : Sprite = $Graphics.get_child(i)
	sprite.show()
	sprite.rotation = (randi() % 4) * PI / 2
	if play_death_sound:
		$DeathSounds.play()
