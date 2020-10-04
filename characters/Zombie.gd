extends Enemy

enum STATES {IDLE, ATTACK}
var cur_state = STATES.IDLE

export var move_speed = 40
var repel_amount = 0.5
func _physics_process(_delta):
	if cur_state == STATES.IDLE:
		if has_los_target_pos(player.global_position):
			cur_state = STATES.ATTACK
		return
	
	var move_vec = get_move_vec_to_point(player.global_position) #global_position.direction_to(player.global_position)
	var repel_vec = get_repulsion_vector()
	var updated_move_vec = move_vec * (1.0 - repel_amount) + repel_vec * repel_amount
	move_and_slide(updated_move_vec * move_speed, Vector2(), false, 4, 0.785398, false)
	for i in range(get_slide_count()):
		var coll : KinematicCollision2D = get_slide_collision(i)
		if coll.collider is RopeNode:
			coll.collider.push(global_position.direction_to(coll.position))

	play_move_anim(move_vec)

