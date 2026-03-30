extends Node

@onready var menu:= $".."

@onready var master: HSlider = $"TabContainer/Nastavení/Options/MasterVolume"
@onready var music: HSlider = $TabContainer/Nastavení/Options/Music
@onready var sfx: HSlider = $TabContainer/Nastavení/Options/SFX
@onready var dub: HSlider = $TabContainer/Nastavení/Options/Dub

@onready var windowed_mode: OptionButton = $TabContainer/Nastavení/Options/WindowedMode
@onready var render_scale: OptionButton = $TabContainer/Nastavení/Options/RenderScale
@onready var anti_aliasing: OptionButton = $TabContainer/Nastavení/Options/AntiAliasing

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
		_windowed_mode(settingsData.windowed_mode_id)

		settingsData.first_load = false
		save_data()
	else:
		_windowed_mode(settingsData.windowed_mode_id)
		_anti_aliasing(settingsData.aa_id)
	
	master.value = settingsData.master_volume
	music.value = settingsData.music_volume
	sfx.value = settingsData.sfx_volume
	dub.value = settingsData.dub_volume
	_windowed_mode(settingsData.windowed_mode_id)
	windowed_mode.select(settingsData.windowed_mode_id)
	_render_scale(settingsData.render_scale_id)
	render_scale.select(settingsData.render_scale_id)
	_anti_aliasing(settingsData.aa_id)
	anti_aliasing.select(settingsData.aa_id)

func save_data():
	ResourceSaver.save(settingsData, save_file_path + save_file_name)

func _master_volume(value: float):
	print("MASTER CHANGED:", value)
	settingsData.master_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(settingsData.master_volume))
func _music_volume(value: float):
	settingsData.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(settingsData.music_volume))
func _sfx_volume(value: float):
	settingsData.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(settingsData.sfx_volume))
func _dub_volume(value: float):
	settingsData.dub_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Dub"), linear_to_db(settingsData.dub_volume))
func _windowed_mode(index: int):
	settingsData.windowed_mode_id = index
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _render_scale(index: int):
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

func _on_button_back_pressed() -> void:
	save_data()
	$".".hide()
func _anti_aliasing(index: int) -> void:
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
