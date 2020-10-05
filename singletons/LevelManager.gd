extends Node

onready var anim_player = $CanvasLayer/AnimationPlayer

var player_max_health = -1
var player_cur_health = -1

var level_list = [
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

func complete_level_load():
	cur_level_ind += 1
	if cur_level_ind >= level_list.size():
		cur_level_ind = 0
		player_max_health = -1
		player_cur_health = -1
	get_tree().call_group("instanced", "queue_free")
	get_tree().change_scene(level_list[cur_level_ind])
	anim_player.play("fadein")

func get_cur_level_number():
	return cur_level_ind

func get_level_count():
	return level_list.size() - 3
