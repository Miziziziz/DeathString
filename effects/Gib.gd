extends KinematicBody2D

var travel_dir : Vector2
var move_speed = 0.0
var speed_scale = 1.0

var min_move_speed = 90.0
var max_move_speed = 120.0
var gib_scale_randomness = 0.2
var velo_retained_on_bounce = 0.5
onready var graphics = $Sprite

var max_vertical_bounce_time = 0.4
var min_vertical_bounce_time = 0.3
var vertical_bounce_time = 0.0
var cur_vertical_bounce_time = 0.0
var min_bounce_height = 30.0
var max_bounce_height = 40.0
var bounce_height = 0.0
export(Curve) var bounce_curve

func _ready():
	travel_dir = Vector2.RIGHT.rotated(deg2rad(rand_range(0.0, 360.0)))
	move_speed = rand_range(min_move_speed, max_move_speed)
	var gib_random_scale = rand_range(-gib_scale_randomness, gib_scale_randomness)
	scale += Vector2.ONE * gib_random_scale
	bounce_height = rand_range(min_bounce_height, max_bounce_height)
	vertical_bounce_time = rand_range(min_vertical_bounce_time, max_vertical_bounce_time)

func _physics_process(delta):
	if speed_scale < 0.2:
		set_physics_process(false)
	var coll = move_and_collide(travel_dir * move_speed * delta * speed_scale, false)
	if coll:
		var d = travel_dir
		var n = coll.normal
		var r = d - 2 * d.dot(n) * n
		travel_dir = r
		rand_rotation()
		speed_scale *= velo_retained_on_bounce
	cur_vertical_bounce_time += delta
	
	var t = bounce_curve.interpolate(cur_vertical_bounce_time / vertical_bounce_time)
	graphics.position.y = -t * bounce_height * speed_scale
	if cur_vertical_bounce_time >= vertical_bounce_time:
		cur_vertical_bounce_time = vertical_bounce_time
		cur_vertical_bounce_time = 0
		speed_scale *= velo_retained_on_bounce
		rand_rotation()
		

func rand_rotation():
	graphics.global_rotation_degrees = rand_range(0.0, 360.0)
