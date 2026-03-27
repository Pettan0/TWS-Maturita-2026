extends Control

@onready var settings:= $Settings
@onready var credits: Panel = $Credits

@onready var button_new_start: Button = $Buttons/ButtonNewStart
@onready var button_continue: Button = $Buttons/ButtonContinue
@onready var button_restart: Button = $Buttons/ButtonRestart
@onready var debug: Panel = $Debug

var menu_show = false

var save_file_path = "user://save/"
var save_file_name = "PlayerData.tres"

var player_data : PlayerData


func load_data():
	if not DirAccess.dir_exists_absolute(save_file_path):
		DirAccess.make_dir_recursive_absolute(save_file_path)

	if FileAccess.file_exists(save_file_path + save_file_name):
		player_data = ResourceLoader.load(save_file_path + save_file_name)
		button_continue.show()
		button_restart.show()
		button_new_start.hide()

	if player_data == null:
		button_continue.hide()
		button_restart.hide()
		button_new_start.show()
func save_data():
	ResourceSaver.save(player_data, save_file_path + save_file_name)

func _ready() -> void:
	load_data()
	$Credits/ScrollContainer/VBoxContainer/Names7.text = OS.get_environment("USERNAME") + " - za hraní této hry :D"
	settings.hide()
	credits.hide()
	debug.hide()
	$Transition.visible = true
	$Transition/AnimationPlayer.play("Fade_out")
	await  get_tree().create_timer(1.0).timeout
	$Transition.visible = false

func _on_button_continue_pressed() -> void:
	if !settings.visible and !credits.visible and !debug.visible:
		$Transition.visible = true
		$Transition/AnimationPlayer.play("Fade_in")
		await  get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Levels/Level0"+str(player_data.level)+".scn")

func _on_button_restart_pressed() -> void:
	if !settings.visible and !credits.visible and !debug.visible:
		player_data = PlayerData.new()
		save_data()
		$Transition.visible = true
		$Transition/AnimationPlayer.play("Fade_in")
		await  get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Levels/Level01.scn")


func _on_button_new_start_pressed() -> void:
	if !settings.visible and !credits.visible and !debug.visible:
		player_data = PlayerData.new()
		save_data()
		$Transition.visible = true
		$Transition/AnimationPlayer.play("Fade_in")
		await  get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Levels/Level01.scn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _settings_show() -> void:
	if !settings.visible and !credits.visible and !debug.visible:
		settings.show()
	else:
		settings.hide()

func _on_credits_pressed() -> void:
	if !settings.visible and !credits.visible and !debug.visible:
		credits.show()
	else:
		credits.hide()

func _on_button_debug_pressed() -> void:
	if !settings.visible and !credits.visible and !debug.visible:
		debug.show()
	else:
		debug.hide()

func _on_credits_button_pressed() -> void:
	credits.hide()

func _on_button_level_1_pressed() -> void:
	player_data.update_level_stats(1,1)
	save_data()
	get_tree().change_scene_to_file("res://Levels/Level0"+str(player_data.level)+".scn")

func _on_button_level_2_pressed() -> void:
	player_data.update_level_stats(2,1)
	save_data()
	get_tree().change_scene_to_file("res://Levels/Level0"+str(player_data.level)+".scn")

func _on_button_level_3_pressed() -> void:
	player_data.update_level_stats(3,1)
	save_data()
	get_tree().change_scene_to_file("res://Levels/Level0"+str(player_data.level)+".scn")

func _on_button_level_4_pressed() -> void:
	player_data.update_level_stats(4,1)
	save_data()
	get_tree().change_scene_to_file("res://Levels/Level0"+str(player_data.level)+".scn")

func _on_button_level_5_pressed() -> void:
	player_data.update_level_stats(5,1)
	save_data()
	get_tree().change_scene_to_file("res://Levels/Level0"+str(player_data.level)+".scn")

func _on_button_level_test_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/LevelTest.tscn")
