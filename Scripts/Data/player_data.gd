extends Resource
class_name PlayerData

#levels stats
@export var level : int = 1
@export var starter_position : Vector3
@export var starter_rotation : Vector3
@export var starter_point : int = 1
@export var difficulty_scale : float = 1.0

#level a xp veci
@export var player_level : int = 1
@export var xp : float = 0
@export var xp_to_next : float = 75
@export var skill_points : int = 0

#player hp stats
@export var max_hp : float = 100
@export var hp : float = max_hp

@export var deaths : int = 0

#hp regen veci
@export var u_hp_regen : bool = false
@export var rtimer_to_wait : float = 10.0
@export var r_per_time  : float = 0.5

#stamina
@export var max_stamina : float = 100
@export var stime_to_wait : float = 1.8
@export var sregen : float = 0.3

#boj veci
@export var base_dmg : float = 1.0

@export var attack_speed : float = 1.0
@export var attack_stamina : int = 15.0
@export var stamina_reduction :float = 1.0

@export var can_block : bool = false
@export var block_dmg : float = 0.2

@export var can_kick : bool = false
@export var kick_dmg : float = 10.0
@export var kick_cooldown : int = 20

@export var have_key : bool = false

#weapons
@export var current_weapon : String = "unarmed"

@export var u_dagger : bool = false
@export var u_short_sword : bool = false
@export var u_mace : bool = false
@export var u_long_sword : bool = false
@export var u_pole_hammer : bool = false

#skill tree veci
@export var unlocked_nodes : Array[Dictionary] = []
@export var skill_tree_changed : bool = false

func upgrade_skill(id:String):
	match id:
		"dmgB":
			base_dmg += 0.10
		"dmgA":
			base_dmg += 0.35
		"attackSpeedB":
			attack_speed += 0.1
		"attackSpeedA":
			attack_speed += 0.3
		"attackStaminaB":
			attack_stamina = attack_stamina * 0.85
			
		"attackStaminaA":
			attack_stamina = attack_stamina * 0.50
		
		"uBlock":
			can_block = true
		"upBlockB":
			block_dmg += 0.15
		"upBlockA":
			block_dmg = 1.0
		"hpB":
			max_hp += 10
			hp += 10
		"hpA":
			max_hp += 30
			hp += 30
		"uKick":
			can_kick = true
		"kickUp":
			kick_cooldown -= 5
		"kickDmg":
			kick_dmg *= 2
		"staminaB":
			max_stamina = round(max_stamina * 1.1)
		"staminaA":
			max_stamina = round(max_stamina * 1.3) 
		"staminaRegenB":
			sregen += 0.075
		"staminaRegenA":
			sregen += 0.075 * 3
		"uRegen":
			u_hp_regen = true
		"regenTime":
			rtimer_to_wait -= 2.5
		"regenUp":
			r_per_time *= 2
	
func update_level_stats(lvl:int, point:int):
	level = lvl
	starter_point = point

func find_starter_position():
	match level:
		1:
			match starter_point:
				1:
					starter_position = Vector3(4.719, 0.461, -0.666)
					starter_rotation = Vector3(0, 0, 0)
				2:
					starter_position = Vector3(23.541, 0.81, -6.182)
					starter_rotation = Vector3(0, 74.3, 0)
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
					starter_position = Vector3(56.448, 0.672, -49.789)
					starter_rotation = Vector3(0, 96.6, 0)
				2:
					starter_position = Vector3(21.625, -0.011, -26.499)
					starter_rotation = Vector3(0, -71.2, 0)
		4:
			match starter_point:
				1:
					starter_position = Vector3(13.57, 1.742, -4.638)
					starter_rotation = Vector3(0, 96.6, 0)
				2:
					starter_position = Vector3(0, 0, 0)
					starter_rotation = Vector3(0, -57.0, 0)
		5:
			match starter_point:
				1:
					starter_position = Vector3(13.57, 1.376, -4.638)
					starter_rotation = Vector3(0, 96.6, 0)
				2:
					starter_position = Vector3(13.57, 1.376, -4.638)
					starter_rotation = Vector3(0, 96.6, 0)
		6:
			match starter_point:
				1:
					starter_position = Vector3(13.011, 1.3, -4.905)
					starter_rotation = Vector3(0, 86.8, 0)
func new_xp_to_next(amount:float):
	var saved_value = amount + xp - xp_to_next
	xp_to_next = round(75 * pow(1.3 , player_level))
	xp = saved_value
	player_level += 1
	skill_points += 2
	print("new xp needed: "+str(xp_to_next)+"\nlevel: "+str(player_level))
