extends StaticBody2D

class_name Boss

enum STATES {IDLE, FIRST_STAGE, SECOND_STAGE, DEAD}
var cur_state = STATES.IDLE

onready var anim_player = $Graphics/AnimationPlayer

var player = null
onready var health_nodes = []
var first_stage_health = 0

var energy_bullet_obj = preload("res://projectiles/EnergyBullet.tscn")
export var num_of_small_projectiles_to_fire = 10
export var small_projectile_fire_rate = 2.0
var fire_rotation_offset = 0.0

var large_energy_bullet_obj = preload("res://projectiles/LargeEnergyBullet.tscn")
var large_projectile_fire_rate = 3.0

export var second_stage_health = 3

var cur_fire_time = 0.0

var start_health = 0
signal awoken
signal died
signal health_updated

func _ready():
	health_nodes = $HealthNodes.get_children() + $HealthNodes2.get_children()
	player = get_tree().get_nodes_in_group("player")[0]
	first_stage_health = health_nodes.size()
	for health_node in health_nodes:
		health_node.connect("died", self, "hurt")
	$PlayerDetector.connect("body_entered", self, "hurt_player")
	
	start_health = second_stage_health + first_stage_health
	connect("health_updated", $CanvasLayer/BossHealthDisplay, "update_health")
	emit_updated_health()

func hurt_player(coll):
	if coll.has_method("hurt"):
		coll.hurt()

func _process(delta):
	match cur_state:
		STATES.FIRST_STAGE:
			process_state_first_stage(delta)
		STATES.SECOND_STAGE:
			process_state_second_stage(delta)

func process_state_first_stage(delta):
	cur_fire_time += delta
	if cur_fire_time >= small_projectile_fire_rate and anim_player.current_animation != "attack":
		cur_fire_time = 0.0
		anim_player.play("attack")

func process_state_second_stage(delta):
	cur_fire_time += delta
	if cur_fire_time >= large_projectile_fire_rate and anim_player.current_animation != "attack":
		cur_fire_time = 0.0
		anim_player.play("attack")

func fire_projectile():
	if cur_state == STATES.SECOND_STAGE:
		fire_large_projectile()
	else:
		fire_small_projectiles()
	anim_player.play("idle", 0.2)

func fire_small_projectiles():
	var angle_between_shots = 2 * PI / num_of_small_projectiles_to_fire
	for i in range(num_of_small_projectiles_to_fire):
		var energy_bullet_inst = energy_bullet_obj.instance()
		get_tree().get_root().add_child(energy_bullet_inst)
		energy_bullet_inst.global_position = global_position
		var r = i * angle_between_shots
		energy_bullet_inst.move_vec = Vector2.RIGHT.rotated(r + fire_rotation_offset * angle_between_shots)
	fire_rotation_offset += 0.2
	if fire_rotation_offset > 1.0:
		fire_rotation_offset = 0.0

func fire_large_projectile():
	var large_energy_bullet_inst = large_energy_bullet_obj.instance()
	get_tree().get_root().add_child(large_energy_bullet_inst)
	large_energy_bullet_inst.global_position = global_position
	large_energy_bullet_inst.move_vec = global_position.direction_to(player.global_position)

func set_state_first_stage():
	cur_state = STATES.FIRST_STAGE
	cur_fire_time = 0.0
	for child in get_children():
		if child is EnemySpawner:
			child.start_spawning()

func set_state_second_stage():
	cur_state = STATES.SECOND_STAGE
	cur_fire_time = 0.0

func set_state_dead():
	cur_state = STATES.DEAD
	for child in get_children():
		if child is EnemySpawner:
			child.stop_spawning()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("kill"):
			enemy.kill(true)
	for large_enemy_bullet in get_tree().get_nodes_in_group("large_energy_bullets"):
		if large_enemy_bullet.has_method("destroy"):
			large_enemy_bullet.destroy()
	for enemy_bullet in get_tree().get_nodes_in_group("energy_bullets"):
		if enemy_bullet.has_method("destroy"):
			enemy_bullet.destroy()
	emit_signal("died")
	anim_player.play("dead")

func hurt():
	if cur_state == STATES.DEAD:
		return
	if cur_state == STATES.IDLE:
		set_state_first_stage()
	
	if anim_player.current_animation != "attack":
		anim_player.play("hurt")
	if first_stage_health > 0:
		first_stage_health -= 1
		if first_stage_health == 0:
			set_state_second_stage()
	else:
		second_stage_health -= 1
		$ElectrifiedEffect.start_effect()
		if second_stage_health <= 0:
			set_state_dead()
	emit_updated_health()

func play_idle_anim():
	if anim_player.current_animation == "hurt":
		anim_player.play("idle")

func emit_updated_health():
	emit_signal("health_updated", first_stage_health + second_stage_health, start_health)
