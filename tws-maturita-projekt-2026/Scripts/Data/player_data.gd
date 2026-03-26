extends Resource
class_name PlayerData

#levels stats
@export var level : int = 1
@export var starter_position : Vector3
@export var starter_rotation : Vector3
@export var starter_point : int = 1

#player hp stats
@export var max_hp : float = 30
@export var hp : float = max_hp

#weapons
@export var u_dagger : bool = true
@export var u_short_swort : bool = true
@export var u_mace : bool = true
@export var u_long_sword : bool = true
@export var u_pole_hammer : bool = true

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
					starter_position = Vector3(58.147, 0.564, -51.7)
					starter_rotation = Vector3(0, 96.6, 0)
				2:
					starter_position = Vector3(-1.798, 1.069, -0.148)
					starter_rotation = Vector3(0, -57.0, 0)

func update_hp(dmg:int):
	hp -= dmg
