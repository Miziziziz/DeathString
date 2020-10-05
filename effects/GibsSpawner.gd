extends Node2D

export var min_gibs_spawned = 4
export var max_gibs_spawned = 7

const MAX_NUM_OF_GIBS_IN_SCENE = 50

var gib_obj = preload("res://effects/Gib.tscn")
var death_impact_obj = preload("res://effects/DeathImpact.tscn")
var blood_splat_obj = preload("res://effects/BloodSplat.tscn")

func spawn_gibs():
	var death_impact_inst = death_impact_obj.instance()
	get_tree().get_root().add_child(death_impact_inst)
	death_impact_inst.global_position = global_position
	
	var blood_splat_inst = blood_splat_obj.instance()
	get_tree().get_root().add_child(blood_splat_inst)
	blood_splat_inst.global_position = global_position
	
	var num_of_gibs_to_spawn = (randi() % (max_gibs_spawned - min_gibs_spawned)) + min_gibs_spawned
	for _i in range(num_of_gibs_to_spawn):
		var gib_inst = gib_obj.instance()
		get_tree().get_root().add_child(gib_inst)
		gib_inst.global_position = global_position
	
	var gibs_in_scene = get_tree().get_nodes_in_group("gibs")
	if gibs_in_scene.size() > MAX_NUM_OF_GIBS_IN_SCENE:
		var i = 0
		for gib in gibs_in_scene:
			if i > gibs_in_scene.size() - MAX_NUM_OF_GIBS_IN_SCENE:
				break
			gib.queue_free()
			i += 1
			
