extends GridContainer


func update_health(cur_health, max_health):
	var ind = 0
	for child in get_children():
		if ind < cur_health:
			child.get_node("HeartFull").show()
		else:
			child.get_node("HeartFull").hide()
		if ind < max_health:
			child.show()
		else:
			child.hide()
		ind += 1
