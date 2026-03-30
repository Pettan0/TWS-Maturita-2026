extends Button

var selected_skill_id = ""
var selected_max_lvl = 0
var selected_lvl = 0

func upgrade():
	match selected_skill_id:
		"dmg1":
			pass
		"spd1":
			pass
		

func set_selected_skill_stats(id,lvl,max_lvl):
	selected_skill_id = id
	selected_lvl = lvl
	selected_max_lvl = max_lvl
