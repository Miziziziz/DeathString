extends Enemy

enum STATES {IDLE, CHARGE, READY_CHARGE, WALK}
var cur_state = STATES.IDLE

export var walk_speed = 40
export var charge_speed = 200
var charge_dir : Vector2

var repel_amount = 0.5
export var time_to_spend_charging = 1.0
export var time_to_spend_readying_charge = 2.0
var time_in_charge_state = 0.0
var time_in_ready_charge_state = 0.0

func _physics_process(delta):
	if cur_state == STATES.IDLE:
		if has_los_target_pos(player.global_position):
			$AlertSounds.play()
			set_state_ready_charge()
		return
	
	match cur_state:
		STATES.READY_CHARGE:
			process_state_ready_charge(delta)
		STATES.CHARGE:
			process_state_charge(delta)
		STATES.WALK:
			process_state_walk(delta)

var about_to_charge = false
func set_state_ready_charge():
	cur_state = STATES.READY_CHARGE
	about_to_charge = false
	anim_player.play("ready_charge")
	time_in_ready_charge_state = 0.0

func set_state_charge():
	cur_state = STATES.CHARGE
	charge_dir = global_position.direction_to(player.global_position)
	anim_player.play("spin")
	time_in_charge_state = 0.0

func set_state_walk():
	cur_state = STATES.WALK

func process_state_charge(delta):
	time_in_charge_state += delta
	
	if time_in_charge_state >= time_to_spend_charging:
		$ChargeSound.stop()
		set_state_walk()
		
	move_and_slide(charge_dir * charge_speed, Vector2(), false, 4, 0.785398, false)
	for i in range(get_slide_count()):
		var coll : KinematicCollision2D = get_slide_collision(i)
		if coll.collider is RopeNode:
			coll.collider.push(global_position.direction_to(coll.position) * 2.0)

func process_state_ready_charge(delta):
	time_in_ready_charge_state += delta
	if time_in_ready_charge_state  >= time_to_spend_readying_charge / 2.0 and !about_to_charge:
		anim_player.stop()
		anim_player.play("ready_charge", -1, 2.0)
		$ChargeSound.play()
		#anim_player.play("spin")
		about_to_charge = true
	if time_in_ready_charge_state >= time_to_spend_readying_charge:
		set_state_charge()

func process_state_walk(delta):
	if has_los_target_pos(player.global_position):
		set_state_ready_charge()
		return
	var move_vec = get_move_vec_to_point(player.global_position)
	var repel_vec = get_repulsion_vector()
	var updated_move_vec = move_vec * (1.0 - repel_amount) + repel_vec * repel_amount
	move_and_slide(updated_move_vec * walk_speed, Vector2(), false, 4, 0.785398, false)
	for i in range(get_slide_count()):
		var coll : KinematicCollision2D = get_slide_collision(i)
		if coll.collider is RopeNode:
			coll.collider.push(global_position.direction_to(coll.position) * 4.0)
	play_move_anim(move_vec)

