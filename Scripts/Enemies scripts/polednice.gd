extends CharacterBody3D
signal died

@onready var player: CharacterBody3D = $"../Player"
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
@onready var hp_bar: Sprite3D = $Sprite3D

@export var area : Area3D

var state_machine
var base_hp = 670
var ATTACK_RANGE = 1.5
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
	if is_dead: return # Stop logic if dead

	var current_node = state_machine.get_current_node()
	
	match current_node:
		"Idle":
			velocity = Vector3.ZERO
			if area and area._is_player_in_area():
				animation_tree.set("parameters/conditions/Move", true)
				
		"Move":
			_handle_movement(delta)
			
		"Melee01":
			_face_target(delta)
			# The animation player should call _hit_player via an Animation Track (Call Method)
			# instead of checking every frame in physics_process.
			
		"Range":
			_face_target(delta)
			if _target_in_range():
				animation_tree.set("parameters/conditions/Melee", true)
				animation_tree.set("parameters/conditions/Range", false) # Reset Range

	move_and_slide()

func _handle_movement(_delta):
	if not player: return
	
	# Determine target position (keep distance or close in)
	var dist = global_position.distance_to(player.global_position)
	nav_agent.set_target_position(player.global_position)

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	
	velocity = direction * SPEED
	_face_target(_delta)

	# State Transitions
	if dist <= ATTACK_RANGE:
		animation_tree.set("parameters/conditions/Melee", true)
		animation_tree.set("parameters/conditions/Move", false)
	elif dist <= 25.0:
		# If you want them to shoot while moving, don't set Move to false
		animation_tree.set("parameters/conditions/Range", true)

func _face_target(delta):
	if player:
		var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)
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

# --- Data Handling ---
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
