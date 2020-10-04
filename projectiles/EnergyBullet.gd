extends KinematicBody2D


var move_speed = 200
var move_vec : Vector2

func _physics_process(delta):
	var coll = move_and_collide(move_vec * move_speed * delta)
	if coll:
		if coll.collider.has_method("hurt"):
			coll.collider.hurt()
		# spawn hit effect
		queue_free()
