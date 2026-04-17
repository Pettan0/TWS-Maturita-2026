extends Resource
class_name SettingsData

@export var master_volume = 1.0
@export var music_volume = 1.0
@export var sfx_volume = 1.0
@export var dub_volume = 1.0
@export var windowed_mode_id = 0
@export var render_scale_id = 0
@export var aa_id = 0
@export var enemy_hp_bar = 0

@export var first_load = true

func hp_bar():
	match enemy_hp_bar:
		0:
			return true
		1:
			return false
