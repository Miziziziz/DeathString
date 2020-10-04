extends KinematicBody2D

onready var anim_player = $AnimationPlayer

const MAX_POSSIBLE_HEALTH = 10
export var max_health = 2
var cur_health = 2
signal health_updated
signal died
var dead = false
var invincible = false

export var max_speed = 400
export var move_accel = 80
var drag = 0.0
var velocity = Vector2()

var string_bullet_obj = preload("res://projectiles/StringBullet.tscn")
var string_bullet : StringBullet

var shoot_released = false
var rope_active = false

const MAX_ROPE_LENGTH = 500
const DIST_BETWEEN_ROPE_NODES = 5
var rope_obj = preload("res://projectiles/RopeNode.tscn")
var rope_nodes = []
var cur_active_rope_node_ind = -1

export var rope_normal_color : Color
export var rope_kill_color : Color
export var max_rope_width = 4.0
export var min_rope_width = 1.0
export var rope_kill_width = 7.0
export var extra_rope_kill_width = 4.0
export var extra_lightning_jitter_variance = 7.0
export var max_lightning_jitter_variance = 7.0
var use_rope_kill_graphics = false

onready var bullet_can_collide_with_player_timer = $BulletCanCollideWithPlayerTimer
onready var deactivate_rope_timer = $DeactivateRopeTimer
onready var rope_kill_anim_timer = $RopeKillAnimTimer

var cursor_open_img = preload("res://sprites/crosshair_open.png")
var cursor_closed_img = preload("res://sprites/crosshair_closed.png")

export var extra_screen_shake_amnt = 3.0
export var max_screen_shake_amnt = 1.0
var just_killed_something = false

func _ready():
	connect("health_updated", $CanvasLayer/HealthDisplay, "update_health")
	if LevelManager.player_cur_health > 0:
		cur_health = LevelManager.player_cur_health
	if LevelManager.player_max_health > 0:
		max_health = LevelManager.player_max_health
	emit_health_updated()
	
	$PickupsDetector.connect("area_entered", self, "pickup_item")
	
	$InvincibilityTimer.connect("timeout", self, "disable_invincibility")
	
	set_cursor_open()
	drag = float(move_accel) / max_speed
	string_bullet = string_bullet_obj.instance()
	get_tree().get_root().call_deferred("add_child", string_bullet)
	string_bullet.deactivate()
	
	string_bullet.connect("returned_to_player", self, "kill_all_touching_rope")
	string_bullet.connect("returned_to_player", self, "bullet_can_collide_with_player")
	string_bullet.connect("returned_to_player", self, "bullet_returned")
	for _i in range(MAX_ROPE_LENGTH / DIST_BETWEEN_ROPE_NODES):
		var rope_node_inst = rope_obj.instance()
		get_tree().get_root().call_deferred("add_child", rope_node_inst)
		rope_node_inst.deactivate()
		rope_node_inst.add_collision_exception_with(self)
		rope_nodes.append(rope_node_inst)

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().call_group("instanced", "queue_free")
		get_tree().reload_current_scene()
	
	if dead:
		return
	
	if use_rope_kill_graphics: # screen shake
		var screen_shake_amnt = max_screen_shake_amnt
		if just_killed_something:
			screen_shake_amnt += extra_screen_shake_amnt
		$Camera2D.offset = Vector2(rand_range(-screen_shake_amnt, screen_shake_amnt), rand_range(-screen_shake_amnt, screen_shake_amnt))
	else:
		$Camera2D.offset = Vector2.ZERO
	
	
	if Input.is_action_just_pressed("shoot") and !string_bullet.active:
		if rope_active:
			deactivate_rope_timer.stop()
		deactivate_rope()
		rope_active = true
		string_bullet.add_collision_exception_with(self)
		bullet_can_collide_with_player_timer.start()
		shoot_released = false
		var aim_dir = (get_global_mouse_position() - global_position).normalized()
		string_bullet.shoot(global_position, aim_dir)
		set_cursor_closed()
	
	if Input.is_action_pressed("shoot") and shoot_released and string_bullet.active:
		string_bullet.shoot(string_bullet.global_position, (global_position - string_bullet.global_position).normalized())
	
	if Input.is_action_just_released("shoot"):
		if string_bullet.active:
			shoot_released = true
	
func _physics_process(_delta):
	if dead:
		return
	
	var move_vec = Vector2()

	if Input.is_action_pressed("move_up"):
		move_vec += Vector2.UP
	if Input.is_action_pressed("move_down"):
		move_vec += Vector2.DOWN
	if Input.is_action_pressed("move_right"):
		move_vec += Vector2.RIGHT
	if Input.is_action_pressed("move_left"):
		move_vec += Vector2.LEFT
	move_vec = move_vec.normalized()
	
	velocity += move_accel * move_vec - velocity * drag
	velocity = move_and_slide(velocity, Vector2(), false, 4, 0.785398, false)
#	for i in range(get_slide_count()):
#		var coll : KinematicCollision2D = get_slide_collision(i)
#		if coll.collider is RopeNode:
#			coll.collider.push(global_position.direction_to(coll.position * velocity.length()))
	
	if string_bullet.active:
		update_rope()
	elif rope_active:
		string_bullet.global_position = global_position
		tighten_rope()
		tighten_rope(false)
		kill_all_touching_rope()
	update()

func update_rope():
	if !string_bullet.active:
		deactivate_rope()
		return
	
	# pull rope behind bullet
	# move small incremental amount
#	for i in range(10):
#		var ind = 0
#		var last_rope_node : Node2D = string_bullet
#		for rope_node in rope_nodes:
#			if ind > cur_active_rope_node_ind:
#				break
#			var dist_to_last = last_rope_node.global_position.distance_to(rope_node.global_position)
#			if dist_to_last > DIST_BETWEEN_ROPE_NODES:
#				var dir_to_last = -(rope_node.global_position - last_rope_node.global_position) / dist_to_last
#				rope_node.global_position += dir_to_last * 1.0
#				#rope_node.linear_velocity = Vector2.ZERO
#			last_rope_node = rope_node
#			ind += 1
	
	# clamp to required range
	tighten_rope()
	
	# add new rope nodes as rope gets longer
	var dist_to_last_rope_node = 0
	var last_rope_node = string_bullet
	if cur_active_rope_node_ind >= 0:
		last_rope_node = rope_nodes[cur_active_rope_node_ind]
	dist_to_last_rope_node = last_rope_node.global_position.distance_to(global_position)
	var dir_to_last_rope_node = global_position.direction_to(last_rope_node.global_position)
	while dist_to_last_rope_node > DIST_BETWEEN_ROPE_NODES:
		# if rope is too long delete
		if cur_active_rope_node_ind + 1 >= rope_nodes.size():
			string_bullet.deactivate()
			deactivate_rope()
			return
		# otherwise add new rope nodes
		dist_to_last_rope_node -= DIST_BETWEEN_ROPE_NODES
		var new_rope_node_pos = global_position + dir_to_last_rope_node * dist_to_last_rope_node
		
		cur_active_rope_node_ind += 1
		rope_nodes[cur_active_rope_node_ind].activate()
		rope_nodes[cur_active_rope_node_ind].global_position = new_rope_node_pos
		

func tighten_rope(tighten_forward=true):
	var ind = 0
	if tighten_forward:
		var last_rope_node : Node2D = string_bullet
		for rope_node in rope_nodes:
			if ind > cur_active_rope_node_ind:
				rope_node.global_position = global_position
				continue
			var dist_to_last = last_rope_node.global_position.distance_to(rope_node.global_position)
			if dist_to_last > DIST_BETWEEN_ROPE_NODES:
				var dir_from_last = (rope_node.global_position - last_rope_node.global_position) / dist_to_last
				rope_node.global_position = last_rope_node.global_position + dir_from_last * DIST_BETWEEN_ROPE_NODES
			last_rope_node = rope_node
			ind += 1
	else:
		var last_rope_node : Node2D = self
		ind = cur_active_rope_node_ind
		while ind >= 0:
			var rope_node = rope_nodes[ind]
			var dist_to_last = last_rope_node.global_position.distance_to(rope_node.global_position)
			if dist_to_last > DIST_BETWEEN_ROPE_NODES:
				var dir_from_last = (rope_node.global_position - last_rope_node.global_position) / dist_to_last
				rope_node.global_position = last_rope_node.global_position + dir_from_last * DIST_BETWEEN_ROPE_NODES
			last_rope_node = rope_node
			ind -= 1

func deactivate_rope():
	rope_active = false
	for rope_node in rope_nodes:
		rope_node.deactivate()
	cur_active_rope_node_ind = -1
	use_rope_kill_graphics = false
	rope_kill_anim_timer.stop()
	update()

func _draw():
	if cur_active_rope_node_ind < 0:
		return
	var rope_color = rope_normal_color
	var rope_width = rope_kill_width
	if use_rope_kill_graphics:
		rope_color = rope_kill_color
		if just_killed_something:
			rope_width += extra_rope_kill_width
	else:
		var t = cur_active_rope_node_ind / float(rope_nodes.size())
		rope_width = lerp(max_rope_width, min_rope_width, t)
	
	
	var ind = 0
	var last_rope_node = string_bullet
	var last_rope_node_pos = Vector2()
	for rope_node in rope_nodes:
		if ind > cur_active_rope_node_ind:
			break
		if use_rope_kill_graphics and ind != 0:
			var cur_max_jitter_amnt = max_lightning_jitter_variance
			if just_killed_something:
				cur_max_jitter_amnt += extra_lightning_jitter_variance
			var jitter_amnt = rand_range(-cur_max_jitter_amnt, cur_max_jitter_amnt)
			var vec_to_right = last_rope_node_pos.direction_to(rope_node.global_position).rotated(deg2rad(90))
			var next_rope_node_pos = rope_node.global_position + vec_to_right * jitter_amnt
			draw_line(to_local(last_rope_node_pos), to_local(next_rope_node_pos), rope_color, rope_width)
			last_rope_node_pos = next_rope_node_pos
		else:
			draw_line(to_local(last_rope_node.global_position), to_local(rope_node.global_position), rope_color, rope_width)
			last_rope_node_pos = rope_node.global_position
		last_rope_node = rope_node
		
		ind += 1
	draw_line(to_local(last_rope_node.global_position), to_local(global_position), rope_color, rope_width)

func kill_all_touching_rope():
	var killed_something = false
	for rope_node in rope_nodes:
		if rope_node.kill_nearby():
				killed_something = true
	if killed_something:
		just_killed_something = true
		$JustKilledSomethingTimer.start()

func bullet_returned():
	bullet_can_collide_with_player_timer.stop()
	string_bullet.remove_collision_exception_with(self)
	deactivate_rope_timer.start()
	rope_kill_anim_timer.start()
	set_cursor_open()

func bullet_can_collide_with_player():
	string_bullet.remove_collision_exception_with(self)

func toggle_rope_graphics():
	use_rope_kill_graphics = !use_rope_kill_graphics

func set_cursor_open():
	Input.set_custom_mouse_cursor(cursor_open_img, Input.CURSOR_ARROW, Vector2.ONE * 16)

func set_cursor_closed():
	Input.set_custom_mouse_cursor(cursor_closed_img, Input.CURSOR_ARROW, Vector2.ONE * 16)

func disable_invincibility():
	invincible = false
	anim_player.play("idle")

func hurt():
	if invincible:
		return
	if dead:
		return
	invincible = true
	$InvincibilityTimer.start()
	anim_player.play("invincible")
	cur_health -= 1
	emit_health_updated()
	if cur_health <= 0:
		dead = true
		emit_signal("died")
		$CanvasLayer/DeathMessage.show()

func pickup_item(item):
	if item is HealthPickup and cur_health < max_health:
		if item.pickup():
			cur_health += 1
			emit_health_updated()
	if item is MaxHealthIncreasePickup:
		if max_health < MAX_POSSIBLE_HEALTH:
			if item.pickup():
				max_health += 1
				cur_health += 1
				emit_health_updated()
		elif cur_health < max_health:
			if item.pickup():
				cur_health += 1
				emit_health_updated()

func set_just_killed_something_false():
	just_killed_something = false

func emit_health_updated():
	emit_signal("health_updated", cur_health, max_health)
