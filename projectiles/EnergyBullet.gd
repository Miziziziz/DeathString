extends KinematicBody2D


var move_speed = 100
var move_vec : Vector2
var destroyed = false

func _ready():
	$PlayerDetector.connect("body_entered", self, "hurt_player")

func hurt_player(coll):
	if destroyed:
		return
	if coll.has_method("hurt"):
		coll.hurt()
		destroy()

func _physics_process(delta):
	var coll = move_and_collide(move_vec * move_speed * delta)
	if coll:
		if destroyed:
			return
		if coll.collider.has_method("hurt"):
			coll.collider.hurt()
		destroy()

func destroy():
	destroyed = true
	$DeleteTimer.start()
	$CollisionShape2D.set_deferred("disabled", true)
	$HitSound.play()
	$Graphics/AnimationPlayer.play("die")
	move_vec = Vector2.ZERO
	#queue_free()
