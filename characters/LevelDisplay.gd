extends Label

func _ready():
	text = "Level: " + str(LevelManager.get_cur_level_number())
	text += "/" + str(LevelManager.get_level_count())
	


