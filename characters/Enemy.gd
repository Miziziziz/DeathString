extends KinematicBody2D

class_name Enemy

onready var anim_player : AnimationPlayer
onready var ally_detector : Area2D
onready var player_detector : Area2D

var player : KinematicBody2D
var nav : Navigation2D

export var char_radius = 3

signal died

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	nav = get_tree().get_nodes_in_group("navigation")[0]
	
	
	if has_node("Graphics/AnimationPlayer"):
		anim_player = $Graphics/AnimationPlayer
	if has_node("AllyDetector"):
		ally_detector = $AllyDetector
	if has_node("PlayerDetector"):
		player_detector = $PlayerDetector
		player_detector.connect("body_entered", self, "hurt_player")
	ready_hook()

func ready_hook():
	pass

func get_move_vec_to_point(goal_pos: Vector2):
	var path = nav.get_simple_path(global_position, goal_pos)
	if path.size() < 2:
		return Vector2.ZERO
	var move_vec = global_position.direction_to(path[1])
	var space_state = get_world_2d().get_direct_space_state()
	
	var right_vec = move_vec.rotated(deg2rad(-90))
	var left_start_pos = to_global(right_vec * char_radius)
	var right_start_pos = to_global(-right_vec * char_radius)
	
	var result_left = space_state.intersect_ray(left_start_pos, left_start_pos + move_vec * 10, [], 1)
	var result_right = space_state.intersect_ray(right_start_pos, right_start_pos + move_vec * 10, [], 1)
	if result_left:
		return move_vec.rotated(deg2rad(30))
	if result_right:
		return move_vec.rotated(deg2rad(-30))
	return move_vec

func hurt_player(coll):
	if coll.has_method("hurt"):
		coll.hurt()

func get_repulsion_vector():
	var repel_vec = Vector2()
	var nearby_chars = ally_detector.get_overlapping_bodies()
	for body in nearby_chars:
		repel_vec += body.global_position.direction_to(global_position)
		repel_vec /= nearby_chars.size()
	return repel_vec

func play_move_anim(travel_dir: Vector2):
	travel_dir = travel_dir.rotated(rad2deg(-135))
	var facing_right = travel_dir.dot(Vector2.RIGHT)
	var facing_up = travel_dir.dot(Vector2.UP)
	
	if facing_right > 0 and facing_up > 0:
		anim_player.play("move_right")
	elif facing_right <= 0 and facing_up > 0:
		anim_player.play("move_up")
	elif facing_right > 0 and facing_up <= 0:
		anim_player.play("move_down") 
	else:
		anim_player.play("move_left")

func _process(delta):
	if has_node("Sprite") and is_instance_valid($Sprite):
		$Sprite.global_rotation = 0.0

func has_los_target_pos(target_pos: Vector2):
	var space_state = get_world_2d().get_direct_space_state()
	var result = space_state.intersect_ray(global_position, target_pos, [], 1)
	if result:
		return false
	return true

var last_tick_hit = 0
var times_hit_this_frame = 0
var dead = false
func kill(instakill=false):
	if dead:
		return false
	var cur_tick = OS.get_ticks_msec()
	if last_tick_hit != cur_tick:
		last_tick_hit = cur_tick
		times_hit_this_frame = 0
	times_hit_this_frame += 1
	if times_hit_this_frame >= 6 or instakill:
		dead = true
		$GibsSpawner.spawn_gibs()
		emit_signal("died")
		queue_free()
		kill_hook()
		return true
	return false

func kill_hook():
	pass
