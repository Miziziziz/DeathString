extends Node2D

export var min_gibs_spawned = 4
export var max_gibs_spawned = 7

var gib_obj = preload("res://effects/Gib.tscn")
var death_impact_obj = preload("res://effects/DeathImpact.tscn")
func spawn_gibs():
	var death_impact_inst = death_impact_obj.instance()
	get_tree().get_root().add_child(death_impact_inst)
	death_impact_inst.global_position = global_position
	
	var num_of_gibs_to_spawn = (randi() % (max_gibs_spawned - min_gibs_spawned)) + min_gibs_spawned
	for _i in range(num_of_gibs_to_spawn):
		var gib_inst = gib_obj.instance()
		get_tree().get_root().add_child(gib_inst)
		gib_inst.global_position = global_position
