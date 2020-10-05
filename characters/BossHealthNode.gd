extends Enemy

var health_pickup_obj = preload("res://pickups/HealthPickup.tscn")

func kill_hook():
	var health_pickup_inst = health_pickup_obj.instance()
	get_tree().get_root().add_child(health_pickup_inst)
	health_pickup_inst.global_position = global_position
