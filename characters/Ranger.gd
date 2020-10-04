extends Enemy

var energy_bullet_obj = preload("res://projectiles/EnergyBullet.tscn")

enum STATES {IDLE, RELOADING, ATTACK, WALK}
var cur_state = STATES.IDLE

export var walk_speed = 40

var repel_amount = 0.5
export var time_to_spend_attacking = 1.0
export var time_to_spend_reloading = 2.0
var time_in_attack_state = 0.0
var time_in_reload_state = 0.0

func _physics_process(delta):
	if cur_state == STATES.IDLE:
		if has_los_target_pos(player.global_position):
			set_state_reloading()
		return
	
	match cur_state:
		STATES.RELOADING:
			process_state_reloading(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.WALK:
			process_state_walk(delta)

var random_move_vec = Vector2.RIGHT
func set_state_reloading():
	cur_state = STATES.RELOADING
	#anim_player.play("ready_charge")
	time_in_reload_state = 0.0
	random_move_vec = Vector2.RIGHT.rotated(rand_range(0.0, 2 * PI))

func set_state_attack():
	cur_state = STATES.ATTACK
	#anim_player.play("spin")
	time_in_attack_state = 0.0
	shoot_projectile()

func shoot_projectile():
	var energy_bullet_inst = energy_bullet_obj.instance()
	get_tree().get_root().add_child(energy_bullet_inst)
	energy_bullet_inst.global_position = global_position
	energy_bullet_inst.move_vec = global_position.direction_to(player.global_position)

func set_state_walk():
	cur_state = STATES.WALK

func process_state_attack(delta):
	time_in_attack_state += delta
	if time_in_attack_state >= time_to_spend_attacking:
		set_state_walk()

func process_state_reloading(delta):
	time_in_reload_state += delta
	if time_in_reload_state >= time_to_spend_reloading:
		set_state_attack()
	
	var repel_vec = get_repulsion_vector()
	var updated_move_vec = random_move_vec * (1.0 - repel_amount) + repel_vec * repel_amount
	move_and_slide(updated_move_vec * walk_speed, Vector2(), false, 4, 0.785398, false)
	for i in range(get_slide_count()):
		var coll : KinematicCollision2D = get_slide_collision(i)
		if coll.collider is RopeNode:
			coll.collider.push(global_position.direction_to(coll.position) * 4.0)
	play_move_anim(random_move_vec)

func process_state_walk(delta):
	if has_los_target_pos(player.global_position):
		set_state_reloading()
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

