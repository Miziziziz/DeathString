extends KinematicBody2D

var move_vec : Vector2
export var move_speed = 100
#var can_hurt_monsters = false
var player : KinematicBody2D

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]

func _physics_process(delta):
	var coll = move_and_collide(move_vec * move_speed * delta, false)
	if coll:
		var thing_hit = coll.collider
		if thing_hit.has_method("kill"):
			thing_hit.kill(true)
			destroy()
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
	collision_mask = 1 + 4 + 16
	$Sprite.self_modulate = Color.blue

func destroy():
	queue_free()
