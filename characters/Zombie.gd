extends KinematicBody2D

var player : KinematicBody2D
var move_speed = 80

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]

func _physics_process(_delta):
	var move_vec = global_position.direction_to(player.global_position)
	move_and_slide(move_vec * move_speed, Vector2(), false, 4, 0.785398, false)
	for i in range(get_slide_count()):
		var coll : KinematicCollision2D = get_slide_collision(i)
		if coll.collider is RopeNode:
			coll.collider.push(global_position.direction_to(coll.position))
		# TODO hurt player

var last_tick_hit = 0
var times_hit_this_frame = 0
func kill():
	var cur_tick = OS.get_ticks_msec()
	if last_tick_hit != cur_tick:
		last_tick_hit = cur_tick
		times_hit_this_frame = 0
	times_hit_this_frame += 1
	if times_hit_this_frame > 5:
		queue_free()
		$GibsSpawner.spawn_gibs()
