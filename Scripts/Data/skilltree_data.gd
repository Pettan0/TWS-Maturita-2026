extends Resource
class_name SkillTreeData

var player_data : PlayerData

@export var skill_points : int = 0

func lvl_up():
	skill_points += 3

func upgrade(id:String):
	match id:
		"dmgB":
			player_data.add_base_dmg(1.0)
		"dmgA":
			player_data.add_base_dmg(5.0)
