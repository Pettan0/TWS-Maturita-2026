extends Node3D
@onready var interact:= $Player/Head/Camera3D/Interact
@onready var area: Area3D = $Area
@onready var npc: Node3D = $Npc
@onready var player: CharacterBody3D = $Player
@onready var item: Node3D = $Item
@onready var weapon_item: Node3D = $Item/dagger
@onready var dialog_hynek_npc: AudioStreamPlayer = $DialogHynekNpc

var save_file_path = "user://save/"
var save_file_name = "PlayerData.tres"

var player_data : PlayerData
var fire_tick = 1.0
var on_fire = false

var can_pick_up_item = false
var near_door = false
var near_npc = false
var talking = false
var talked = false
var can_welcome = true




func _ready():
	load_data()
	$Funny/Label.text = "Ahoj\n"+OS.get_environment("USERNAME")+" :)"

func _process(delta: float) -> void:
	if weapon_item.visible and can_pick_up_item:
		interact.show_with("PickUpItem",weapon_item.name)
	elif !can_pick_up_item and !near_door and !near_npc:
		interact.hide()
		
	if on_fire and fire_tick >= 1.0:
		fire_tick = 0.0
		player._hit(10)
	else:
		fire_tick += delta
func spawn_item():
				#zmenit podle itemu
	if player_data.u_dagger:
		return
	else:
		weapon_item.show()
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
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"): # Use the event passed to the function
		if near_door:
			handle_door_transition()
		elif can_pick_up_item and weapon_item.visible:
			handle_item_pickup()
		elif near_npc and !talking and player.player_data.deaths <= 0:
			handle_npc_talk()

func handle_npc_talk():
	interact.hide()
	talking = true
	player.paused = true
	player.look_at(npc.global_position)
	await npc.start_talk()
	player.paused = false
	talking = false
	talked = true
	

func handle_item_pickup():
	player.player_data.u_dagger = true
	player._weapon_out("dagger")
	weapon_item.hide()
	can_pick_up_item = false

func handle_door_transition():
	save_data()
	SoundManager.play_door_sfx()
	player.transition.fade_in()
	await get_tree().create_timer(1.5).timeout
	# Ensure the level string is padded if necessary (e.g., Level01)
	var level_path = "res://Levels/Level0" + str(player_data.level) + ".scn"
	get_tree().change_scene_to_file(level_path)
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
	if body.name == "Player" and can_welcome:
		npc.say_hi()
		can_welcome = false
func _on_fire_hitbox_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		on_fire = true
func _on_fire_hitbox_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		on_fire = false
func _on_item_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		can_pick_up_item = true
func _on_item_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		can_pick_up_item = false
func _on_near_npc_hitbox_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not talked and player.player_data.deaths <= 0:
		near_npc = true
		interact.show_with("TalkToNpc","")
func _on_near_npc_hitbox_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		near_npc = false
		interact.hide()
