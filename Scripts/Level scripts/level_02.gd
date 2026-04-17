extends Node3D
@onready var interact: Label = $Player/Head/Camera3D/Interact
@onready var player: CharacterBody3D = $Player
@onready var popup: Label = $Player/Head/Camera3D/Popup

var enemies_left = 0
var next_lvl = 0

var save_file_path = "user://save/"
var save_file_name = "PlayerData.tres"

var player_data : PlayerData


func _ready():
	print("Enemies at start:", enemies_left)
	load_data()
	print(player_data.starter_position)
	var enemies = get_tree().get_nodes_in_group("Enemies")
	enemies_left = enemies.size()
	print("Enemies:", enemies_left)

	for enemy in enemies:
		enemy.died.connect(_on_enemy_died)
func _on_enemy_died():
	enemies_left -= 1
	print("Remaining:", enemies_left)
func load_data():
	if not DirAccess.dir_exists_absolute(save_file_path):
		DirAccess.make_dir_recursive_absolute(save_file_path)

	if FileAccess.file_exists(save_file_path + save_file_name):
		player_data = ResourceLoader.load(save_file_path + save_file_name)

	if player_data == null:
		player_data = PlayerData.new()
		save_data()

	player_data.find_starter_position()
	player.position = player_data.starter_position
	player.rotation_degrees = player_data.starter_rotation


func save_data():
	ResourceSaver.save(player_data, save_file_path + save_file_name)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and interact.visible:
		if enemies_left == 0:
			match next_lvl:
				1:
					player_data.update_level_stats(1,2)
				3:
					player_data.update_level_stats(3,1)
			save_data()
			SoundManager.play_door_sfx()
			await get_tree().create_timer(0.5).timeout
			player.transition.fade_in()
			get_tree().change_scene_to_file("res://Levels/Level0"+str(player_data.level)+".scn")
		else:
			popup.show_with("cantEnter")
func _on_exit_door_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		interact.show_with("OpenDoor","")
		next_lvl = 1

func _on_exit_door_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		interact.hide()

func _on_lvl_3_door_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		interact.show_with("OpenDoor","")
		next_lvl = 3


func _on_lvl_3_door_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		interact.hide()


func _locked_door_entered(body: Node3D) -> void:
	if body.name == "Player":
		popup.show_with("blockedDoor")
