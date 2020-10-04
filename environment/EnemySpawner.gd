extends Position2D

class_name EnemySpawner

var enemy_objs = [
	preload("res://characters/Zombie.tscn"),
	preload("res://characters/Bull.tscn"),
	preload("res://characters/Ranger.tscn")
]

func start_spawning():
	$FirstSpawnTimer.wait_time = rand_range(0.0, $SpawnTimer.wait_time)
	$FirstSpawnTimer.start()

func stop_spawning():
	$FirstSpawnTimer.stop()
	$SpawnTimer.stop()

func spawn_enemy():
	var ind = randi() % enemy_objs.size()
	var enemy_obj = enemy_objs[ind]
	var enemy_inst = enemy_obj.instance()
	get_tree().get_root().add_child(enemy_inst)
	enemy_inst.global_position = global_position
	enemy_inst.add_to_group("instanced")
