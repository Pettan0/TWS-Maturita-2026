extends Node3D
@onready var interact: Label = $Player/Head/Camera3D/Interact
@onready var player: CharacterBody3D = $Player
@onready var popup: Label = $Player/Head/Camera3D/Popup
@onready var item: Node3D = $wp_polehammer

var enemies_left = 0
var next_lvl = 0
var near_item = false

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
			
		if near_item:
			item.hide()
			player_data.u_pole_hammer = true
			player._weapon_out("poleHammer")
			interact.hide()

func _on_item_area_body_entered(body: Node3D) -> void:
	if body.name == "Player" and item.visible:
		interact.show_with("PickUpItem","poleHammer")
		near_item = true

func _on_item_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		interact.hide()
		near_item = false


func _on_boss_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		$WaaaghdrumD115.stream = load("res://Assets/Sounds/Music/Boss music.wav")
		$WaaaghdrumD115.play()


func _on_boss_enemy_died() -> void:
	get_tree().change_scene_to_file("res://Menu/Main menu.tscn")
