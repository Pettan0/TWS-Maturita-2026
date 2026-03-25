extends Node

@onready var menu:= $".."

var save_file_path = "user://save/"
var save_file_name = "SettingsData.tres"

var settingsData : SettingsData

func _ready():
	load_data()

func load_data():
	if not DirAccess.dir_exists_absolute(save_file_path):
		DirAccess.make_dir_recursive_absolute(save_file_path)
	
	if FileAccess.file_exists(save_file_path + save_file_name):
		settingsData = ResourceLoader.load(save_file_path + save_file_name)
	
	if settingsData == null:
		settingsData = SettingsData.new()
		save_data()
		
	if settingsData.first_load:
		windowed_mode(settingsData.windowed_mode_id)

		settingsData.first_load = false
		save_data()
	else:
		windowed_mode(settingsData.windowed_mode_id)
		aa(settingsData.aa_id)
	
	$Options/HBoxContainer/PanelZvuk/MasterVolume.value = settingsData.master_volume
	$Options/HBoxContainer/PanelZvuk/Music.value = settingsData.music_volume
	$Options/HBoxContainer/PanelZvuk/SFX.value = settingsData.sfx_volume
	$Options/HBoxContainer/PanelZvuk/Dub.value = settingsData.dub_volume
	windowed_mode(settingsData.windowed_mode_id)
	$Options/HBoxContainer/PanelOstatni/WindowedMode.select(settingsData.windowed_mode_id)
	render_scale(settingsData.render_scale_id)
	$Options/HBoxContainer/PanelOstatni/RenderScale.select(settingsData.render_scale_id)
	render_scale(settingsData.aa_id)
	$Options/HBoxContainer/PanelOstatni/AntiAliasing.select(settingsData.aa_id)

func save_data():
	ResourceSaver.save(settingsData, save_file_path + save_file_name)

func master_volume(value: float):
	settingsData.master_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(settingsData.master_volume))

func music_volume(value: float):
	settingsData.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(settingsData.music_volume))

func sfx_volume(value: float):
	settingsData.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(settingsData.sfx_volume))

func dub_volume(value: float):
	settingsData.dub_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Dub"), linear_to_db(settingsData.sfx_volume))


func windowed_mode(index: int):
	settingsData.windowed_mode_id = index
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func render_scale(index: int):
	settingsData.render_scale_id = index
	match index:
		0:
			get_tree().root.scaling_3d_scale = 1.0
		1:
			get_tree().root.scaling_3d_scale = 0.8
		2:
			get_tree().root.scaling_3d_scale = 0.6
		3:
			get_tree().root.scaling_3d_scale = 0.25

func aa(index: int):
	settingsData.aa_id = index
	match index:
		0:
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
			get_viewport().use_taa = false
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		1:
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
			get_viewport().use_taa = false
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		2:
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
			get_viewport().use_taa = true
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		3:
			get_viewport().msaa_3d = Viewport.MSAA_2X
			get_viewport().use_taa = false
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		4:
			get_viewport().msaa_3d = Viewport.MSAA_4X
			get_viewport().use_taa = false
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED

func back() -> void:
	save_data()
	$".".hide()
