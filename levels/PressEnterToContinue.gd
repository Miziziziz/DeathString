extends Control


func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("continue"):
		LevelManager.load_next_level()
