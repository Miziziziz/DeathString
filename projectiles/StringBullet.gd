extends KinematicBody2D

class_name StringBullet

var travel_dir : Vector2
export var move_speed = 500

var active = false

signal returned_to_player

var return_button_held = false

func shoot(pos: Vector2, dir: Vector2):
	show()
	$CollisionShape2D.disabled=false
	set_physics_process(true)
	travel_dir = dir
	global_position = pos
	active = true

func deactivate():
	hide()
	$CollisionShape2D.disabled=true
	set_physics_process(false)
	active = false

func _physics_process(delta):
	var coll = move_and_collide(travel_dir * move_speed * delta, false)
	
	if coll:
		if coll.collider.name == "Player":
			deactivate()
			emit_signal("returned_to_player")
			return
		if !return_button_held:
			var d = travel_dir
			var n = coll.normal
			var r = d - 2 * d.dot(n) * n
			travel_dir = r
		else:
			var n = coll.normal
			global_position += n * 2.0
			n = n.rotated(PI / 2.0)
			if travel_dir.dot(n) > 0:
				travel_dir = n
			else:
				travel_dir= -n
