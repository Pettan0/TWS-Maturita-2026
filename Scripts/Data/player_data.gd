extends Resource
class_name PlayerData

#levels stats
@export var level : int = 1
@export var starter_position : Vector3
@export var starter_rotation : Vector3
@export var starter_point : int = 1

#level a xp veci
@export var player_level : int = 1
@export var xp :float = 0
@export var xp_to_next : float = 75
@export var skill_points : int = 0

#player hp stats
@export var max_hp : float = 100
@export var hp : float = max_hp

#hp regen veci
@export var u_hp_regen : bool = true

@export var rtimer_to_wait : float = 10.0
@export var r_per_time  : float = 0.5

#stamina
@export var max_stamina : float = 100
@export var stime_to_wait : float = 1.8
@export var sregen : float = 0.2

#weapons
@export var current_weapon : String = "unarmed"

@export var base_dmg : float = 0

@export var attack_speed : float = 1.0
@export var attack_stamina : int = 15

@export var u_dagger : bool = true
@export var u_short_swort : bool = true
@export var u_mace : bool = true
@export var u_long_sword : bool = true
@export var u_pole_hammer : bool = true

@export var unlocked_nodes : Array[String] = []

func upgrade_skill(id:String):

	match id:
		"dmgB":
			base_dmg += 1.0
		"dmgA":
			base_dmg += 5.0
		"attackSpeedB":
			attack_speed += 0.1
		"attackSpeedA":
			attack_speed += 0.3
		"attackStaminaB":
			attack_stamina -= 2
		"attackStaminaA":
			attack_stamina -= 4
	print("base dmg: "+str(base_dmg)+"\nattack speed: "+str(attack_speed)+"\nattack stamina: "+str(attack_stamina))
func update_level_stats(lvl:int, point:int):
	level = lvl
	starter_point = point

func find_starter_position():
	match level:
		1:
			match starter_point:
				1:
					starter_position = Vector3(0.117, 0.765, 0.81)
					starter_rotation = Vector3(0, 0, 0)
				2:
					starter_position = Vector3(28.754, 1.197, -7.875)
					starter_rotation = Vector3(0, 81.2, 0)
		2:
			match starter_point:
				1:
					starter_position = Vector3(13.372, 1.069, -5.538)
					starter_rotation = Vector3(0, 96.6, 0)
				2:
					starter_position = Vector3(-1.798, 1.069, -0.148)
					starter_rotation = Vector3(0, -57.0, 0)
		3:
			match starter_point:
				1:
					starter_position = Vector3(58.147, 0.589, -51.7)
					starter_rotation = Vector3(0, 96.6, 0)
				2:
					starter_position = Vector3(16.975, -0.194, -24.469)
					starter_rotation = Vector3(0, -71.2, 0)
		4:
			match starter_point:
				1:
					starter_position = Vector3(13.57, 1.742, -4.638)
					starter_rotation = Vector3(0, 96.6, 0)
				2:
					starter_position = Vector3(0, 0, 0)
					starter_rotation = Vector3(0, -57.0, 0)

func new_xp_to_next(amount:float):
	var saved_value = amount + xp - xp_to_next
	xp_to_next = round(100 * pow(1.25, player_level))
	xp = saved_value
	player_level += 1
	skill_points += 3
	print("new xp needed: "+str(xp_to_next)+"\nlevel: "+str(player_level))
