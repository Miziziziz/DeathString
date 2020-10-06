extends Node

onready var anim_player = $CanvasLayer/AnimationPlayer

var player_max_health = -1
var player_cur_health = -1

var max_num_of_gibs = 50
var rope_nodes_to_skip = 1

func set_graphics_low():
	rope_nodes_to_skip = 3
	max_num_of_gibs = 10
	
func set_graphics_med():
	rope_nodes_to_skip = 2
	max_num_of_gibs = 25
	
func set_graphics_high():
	rope_nodes_to_skip = 1
	max_num_of_gibs = 50

var level_list = [
	"res://levels/MainScreen.tscn",
	"res://levels/Intro.tscn",
	"res://levels/Tutorial.tscn",
	"res://levels/FirstEncounter.tscn",
	"res://levels/SomeMoreZombies.tscn",
	"res://levels/IntroducingBull.tscn",
	"res://levels/BunchaBull.tscn",
	"res://levels/Corridors.tscn",
	"res://levels/MixedCrew.tscn",
	"res://levels/IntroducingRanger.tscn",
	"res://levels/TroopsLine.tscn",
	"res://levels/Snipers.tscn",
	"res://levels/BossFight.tscn",
	"res://levels/Outro.tscn",
	"res://levels/Credits.tscn"
]
var cur_level_ind = 0

func load_next_level():
	if anim_player.current_animation == "fadeout" and anim_player.is_playing():
		return
	anim_player.play("fadeout")
	$EnterPortal.play()

func stop_music():
	$MainGameMusic.stop()

func complete_level_load():
	cur_level_ind += 1
	if cur_level_ind > 1 and cur_level_ind < 12 and !$MainGameMusic.playing:
		$MainGameMusic.play()
	if cur_level_ind >= level_list.size():
		cur_level_ind = 0
		player_max_health = -1
		player_cur_health = -1
	get_tree().call_group("instanced", "queue_free")
	get_tree().change_scene(level_list[cur_level_ind])
	anim_player.play("fadein")

func get_cur_level_number():
	return cur_level_ind - 1

func get_level_count():
	return level_list.size() - 4
