extends RigidBody2D

class_name RopeNode

func deactivate():
	hide()
	$CollisionShape2D.disabled = true
	linear_velocity = Vector2.ZERO

func activate():
	show()
	$CollisionShape2D.disabled = false

func kill_nearby():
	# currently only used for chargin enemy boss projectiles
	var killed_something = false
	for body in $Area.get_overlapping_bodies():
		if body.has_method("kill"):
			if body.kill():
				killed_something = true
	return killed_something

func push(offset: Vector2):
	global_position += offset
