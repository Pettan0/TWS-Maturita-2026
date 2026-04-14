extends Node3D
@onready var interact:= $Player/Head/Camera3D/Interact
@onready var area: Area3D = $Area
@onready var npc: AnimationTree = $Npc/AnimationTree
@onready var player: CharacterBody3D = $Player


var save_file_path = "user://save/"
var save_file_name = "PlayerData.tres"

var player_data : PlayerData
var fire_tick = 1.0
var on_fire = false
var near_door = false


func _ready():
	load_data()
	$Funny/Label.text = "Ahoj\n"+OS.get_environment("USERNAME")+" :)"

func _process(delta: float) -> void:
	if on_fire and fire_tick >= 1.0:
		fire_tick = 0.0
		player._hit(10)
	else:
		fire_tick += delta
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
	if Input.is_action_just_pressed("interact") and interact.visible and near_door:
		save_data()
		SoundManager.play_door_sfx()
		$Player/Transition.visible = true
		$Player/Transition/AnimationPlayer.play("Fade_in")
		await  get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Levels/Level0"+str(player_data.level)+".scn")

func _on_door_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		interact.show_with("OpenDoor","")
		player_data.update_level_stats(2,1)
		near_door = true

func _on_door_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		interact.hide()
		near_door = false


func _on_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		npc.set("parameters/conditions/Hello",true)



func _on_fire_hitbox_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		on_fire = true


func _on_fire_hitbox_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		on_fire = false
