extends Resource
class_name SkillTreeData

@export var player_data : PlayerData
@export var skill_points : int = 0

@export var unlocked_nodes : Array[String] = []
func lvl_up():
	skill_points += 3

func upgrade(id:String):
	if player_data == null:
		print("ERROR: player_data is null")
		return

	match id:
		"dmgB":
			player_data.base_dmg += 1.0
		"dmgA":
			player_data.add_base_dmg += 5.0
		"attackSpeedB":
			player_data.attack_speed += 0.1
		"attackSpeedA":
			player_data.attack_speed += 0.3
		"attackStaminaB":
			player_data.attack_stamina -= 2
		"attackStaminaA":
			player_data.attack_speed -= 4
