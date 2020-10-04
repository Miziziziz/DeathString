extends StaticBody2D


var is_open = false

var num_of_enemies_in_scene = 0

func _ready():
	$PlayerDetector.connect("body_entered", self, "player_entered")
	var enemies_in_scene = get_tree().get_nodes_in_group("enemies")
	num_of_enemies_in_scene = enemies_in_scene.size()
	for enemy in enemies_in_scene:
		if enemy is Enemy:
			enemy.connect("died", self, "enemy_killed")

func open_portal():
	$CollisionShape2D.disabled = true
	is_open = true
	$Sprite.hide()
	$CPUParticles2D.emitting = true

func player_entered(body):
	if is_open:
		LevelManager.player_cur_health = body.cur_health
		LevelManager.player_max_health = body.max_health
		LevelManager.load_next_level()

func enemy_killed():
	num_of_enemies_in_scene -= 1
	if num_of_enemies_in_scene <= 0:
		open_portal()
