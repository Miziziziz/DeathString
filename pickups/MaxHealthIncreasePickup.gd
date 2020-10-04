extends Area2D

class_name MaxHealthIncreasePickup

var picked_up = false

func pickup():
	if picked_up:
		return false
	picked_up = true
	queue_free()
	return true
