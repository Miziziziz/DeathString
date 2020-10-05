extends KinematicBody2D

var move_vec : Vector2
export var move_speed = 100
#var can_hurt_monsters = false
var player : KinematicBody2D

var electrified = false
export var num_lightning_points =12
export var lightning_color : Color
export var lightning_width = 1.2
export var lightning_jitter_amnt = 7.0
export var radius = 16

var destroyed = false

func _ready():
	collision_mask = 1 + 4 # some dumb bs bug
	player = get_tree().get_nodes_in_group("player")[0]
	$PlayerDetector.connect("body_entered", self, "hurt_player")

func hurt_player(coll):
	if destroyed:
		return
	if coll.has_method("hurt") and "Player" in coll.name:
		coll.hurt()
		destroy()
	if electrified and coll.has_method("kill"):
		coll.call_deferred("kill", true)
		return

func _physics_process(delta):
	if electrified:
		update()
	var coll = move_and_collide(move_vec * move_speed * delta, false)
	if coll:
		if destroyed:
			return
		var thing_hit = coll.collider
		if thing_hit.has_method("kill"):
			thing_hit.kill(true)
			#destroy()
			return
		if thing_hit.has_method("hurt"):
			thing_hit.hurt()
			destroy()
			return
		
		var d = move_vec
		var n = coll.normal
		var r = d - 2 * d.dot(n) * n
		move_vec = r

func kill():
	if electrified:
		return
	electrified = true
	
	collision_mask = 1 + 4 + 16
	#$Sprite.self_modulate = Color.blue

func _draw():
	if !electrified:
		return
	var last_point = null
	var first_point : Vector2
	var arc_per_segment = 2 * PI / num_lightning_points
	for i in range(num_lightning_points):
		var jitter_amnt = rand_range(-lightning_jitter_amnt, lightning_jitter_amnt)
		var cur_point = Vector2.RIGHT.rotated(arc_per_segment * i) * (radius + jitter_amnt)
		if last_point != null:
			draw_line(last_point, cur_point, lightning_color, lightning_width)
		else:
			first_point = cur_point
		last_point = cur_point
	draw_line(last_point, first_point, lightning_color, lightning_width)

func destroy():
	destroyed = true
	queue_free()
