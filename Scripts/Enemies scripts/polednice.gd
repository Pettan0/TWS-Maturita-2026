extends CharacterBody3D
signal died

@onready var player: CharacterBody3D = $"../Player"
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
@onready var hp_bar: Sprite3D = $Sprite3D

@export var area : Area3D
@export var TARGET_RADIUS = 10.0
@export var RADIUS_TOLERANCE = 1.0

var state_machine
var base_hp = 670
var ATTACK_RANGE = 2.0
var DMG = 15.0
const SPEED = 5.0
const TURN_SPEED = 10.0 # Speed of rotation

var max_hp
var HP
var is_dead = false

var settingsData : SettingsData
var save_file_path = "user://save/"
var save_file_name = "SettingsData.tres"

func _ready() -> void:
	load_data()
	hp_bar.visible = settingsData.enemy_hp_bar if settingsData else true
	
	# Ensure player data exists before scaling
	if player and player.get("player_data"):
		max_hp = base_hp * player.player_data.difficulty_scale
		DMG = DMG * player.player_data.difficulty_scale
	else:
		max_hp = base_hp

	HP = max_hp
	progress_bar.update_hp(max_hp, HP)
	state_machine = animation_tree.get("parameters/playback")

func _physics_process(delta):
	if is_dead: return
	
	var current_node = state_machine.get_current_node()
	var dist_to_player = global_position.distance_to(player.global_position)
	
	match current_node:
		"idle":
			velocity = Vector3.ZERO
			if area and area._is_player_in_area():
				animation_tree.set("parameters/conditions/Move", true)

		"Move":
			if not player: return
			
			# 1. Target calculation
			var dir_from_player = (global_position - player.global_position).normalized()
			var target_pos = player.global_position + (dir_from_player * TARGET_RADIUS)
			
			nav_agent.set_target_position(target_pos)
			
			# 2. Pathfinding check
			var next_pos = nav_agent.get_next_path_position()
			var direction = (next_pos - global_position).normalized()
			
			# DEBUG: If this prints (0,0,0), your NavMesh is missing or broken
			print("Direction: ", direction) 

			velocity = direction * SPEED
			_face_target(delta)

			# 3. Transitions (Checking these EVERY frame while in Move)
			if dist_to_player <= ATTACK_RANGE:
				print("Triggering Melee!")
				animation_tree.set("parameters/conditions/Melee01", true)
				animation_tree.set("parameters/conditions/Move", false)
			
			elif global_position.distance_to(target_pos) < RADIUS_TOLERANCE:
				print("Triggering Ranged!")
				velocity = Vector3.ZERO
				animation_tree.set("parameters/conditions/Ranged", true)
				animation_tree.set("parameters/conditions/Move", false)

		"Ranged":
			velocity = Vector3.ZERO 
			_face_target(delta)
			
			# Logic to move again if player gets too far/close
			if abs(dist_to_player - TARGET_RADIUS) > 3.0: 
				animation_tree.set("parameters/conditions/Ranged", false)
				animation_tree.set("parameters/conditions/Move", true)
				
			if dist_to_player <= ATTACK_RANGE:
				animation_tree.set("parameters/conditions/Melee01", true)
				animation_tree.set("parameters/conditions/Ranged", false)

		"Melee01":
			velocity = Vector3.ZERO
			_face_target(delta)
			# Usually, the animation itself handles returning to 'Move' or 'idle'

	# MUST be outside the match statement to apply velocity
	move_and_slide()

func _face_target(delta):
	if player:
		var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		if global_position.distance_to(look_target) > 0.1:
			var new_transform = transform.looking_at(look_target, Vector3.UP)
			transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)
func hit(damage_taken: float, _weapon_type: String, _dir: Vector3):
	if is_dead: return
	
	HP -= damage_taken
	progress_bar.update_hp(max_hp, HP)

	if HP <= 0:
		is_dead = true
		animation_tree.set("parameters/conditions/Death", true)
		die(2.0)
		return

	animation_tree.set("parameters/conditions/Hit", true)
	# Use a timer or animation finish signal to set Hit back to false
	await get_tree().create_timer(0.2).timeout
	animation_tree.set("parameters/conditions/Hit", false)

func die(delay: float):
	died.emit()
	$CollisionShape3D.set_deferred("disabled", true)
	await get_tree().create_timer(delay).timeout
	queue_free()

func _hit_player():
	if _target_in_range() and player.has_method("_hit"):
		player._hit(DMG)
		
func _target_in_range():
	return global_position.distance_to(player.global_position) <= ATTACK_RANGE


func load_data():
	if not DirAccess.dir_exists_absolute(save_file_path):
		DirAccess.make_dir_recursive_absolute(save_file_path)
	if FileAccess.file_exists(save_file_path + save_file_name):
		settingsData = ResourceLoader.load(save_file_path + save_file_name)
	if settingsData == null:
		settingsData = SettingsData.new()
		save_data()

func save_data():
	ResourceSaver.save(settingsData, save_file_path + save_file_name)
