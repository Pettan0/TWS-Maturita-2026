extends Node3D
@onready var interact:= $Player/Head/Camera3D/Interact
@onready var area: Area3D = $Area
@onready var npc: AnimationTree = $Npc/AnimationTree
@onready var player: CharacterBody3D = $Player


var save_file_path = "user://save/"
var save_file_name = "PlayerData.tres"

var player_data : PlayerData


func _ready():
	load_data()
	print(player_data.starter_position)


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
		save_data()
		$Player/Transition.visible = true
		$Player/Transition/AnimationPlayer.play("Fade_in")
		await  get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Levels/Level0"+str(player_data.level)+".scn")

func _on_exit_door_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		interact.visible = true
		player_data.update_level_stats(1,2)

func _on_exit_door_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		interact.visible = false

func _on_lvl_3_door_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		interact.visible = true
		player_data.update_level_stats(3,1)

func _on_lvl_3_door_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		interact.visible = false
