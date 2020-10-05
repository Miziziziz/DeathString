extends Node2D

var electrified = false
export var num_lightning_points =12
export var lightning_color : Color
export var lightning_width = 1.2
export var lightning_jitter_amnt = 7.0
export var radius = 16

func start_effect():
	electrified = true
	$Timer.start()
	set_process(true)

func end_effect():
	electrified = false
	set_process(false)
	update()

func _process(delta):
	update()

func _draw():
	if !electrified:
		return
	var last_point = null
	var first_point : Vector2
	var arc_per_segment = 2 * PI / num_lightning_points
	for i in range(num_lightning_points):
		var jitter_amnt = rand_range(-lightning_jitter_amnt, lightning_jitter_amnt)
		var cur_point = Vector2.RIGHT.rotated(arc_per_segment * i) * (radius + jitter_amnt)
		if last_point != null:
			draw_line(last_point, cur_point, lightning_color, lightning_width)
		else:
			first_point = cur_point
		last_point = cur_point
	draw_line(last_point, first_point, lightning_color, lightning_width)

