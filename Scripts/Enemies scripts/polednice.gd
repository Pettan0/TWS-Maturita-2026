extends CharacterBody3D
signal died

const WIND_PROJECTILE_SCENE = preload("res://Assets/Modely/Wind_Projectile.tscn")

@onready var player: CharacterBody3D = $"../Player"
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
@onready var hp_bar: Sprite3D = $Sprite3D
@onready var projectile_spawn_point: Node3D = get_node_or_null("ProjectileSpawnPoint")

@export var area : Area3D
@export var TARGET_RADIUS = 5.0
@export var RADIUS_TOLERANCE = 2.0 # Increased for smoother transitions
@export var MIN_REPOSITION_DISTANCE = 3.0
@export var LEAVE_HOLD_DISTANCE = 2.0
@export var RANGED_SHOT_DELAY = 0.25
@export var RANGED_SHOT_INTERVAL = 1.2
@export var PLAYER_AIM_HEIGHT = 1.0

var base_hp = 670
var ATTACK_RANGE = 4.5
var DMG = 15.0
const SPEED = 5.0
const TURN_SPEED = 10.0

var max_hp
var HP
var is_dead = false
var orbit_target = Vector3.ZERO
var hold_position = Vector3.ZERO
var has_orbit_target = false
var waiting_for_player_hit = false
var move_attack_used = false
var move_attack_in_progress = false
var must_leave_hold_position = false
var ranged_attack_in_progress = false

# --- Standard Godot Setup ---

func _ready() -> void:
	# Load HP/Settings logic here as before...
	max_hp = base_hp
	HP = max_hp
	$SubViewport/ProgressBar.max_value = max_hp
	$SubViewport/ProgressBar.value = HP
# --- Core Logic Functions ---

func _physics_process(delta):
	$SubViewport/ProgressBar.value = HP
	if is_dead: return
	if not is_instance_valid(player):
		velocity = Vector3.ZERO
		move_and_slide()
		return

	var current_node = state_machine.get_current_node()
	var dist_to_player = global_position.distance_to(player.global_position)
	match current_node:
		"idle":
			velocity = Vector3.ZERO
			if area._is_player_in_area():
				_change_state("Move")

		"Move":
			if waiting_for_player_hit:
				_hold_ranged_position(delta)
			else:
				_handle_move_logic(delta, dist_to_player)

		"Ranged":
			_hold_ranged_position(delta)

		"Melee01", "Melee02":
			velocity = Vector3.ZERO
			_face_target(delta)
			# It will automatically return to "Move" when the animation ends
			# thanks to your AnimationTree transitions!

		"Hit":
			velocity = Vector3.ZERO
			# Removed the instant Melee01 transition from here.
			# The hit() function below handles the counter-attack timing now.

	move_and_slide()


func _change_state(state_name: String):
	state_machine.travel(state_name)


# --- Combat Functions ---

func hit(damage_taken: float, _weapon_type: String, _dir: Vector3):
	if is_dead: return
	SoundManager.zoomer_play()
	$hit.play()
	HP -= damage_taken
	progress_bar.update_hp(max_hp, HP)
	if HP <= 0:
		is_dead = true
		_change_state("Death")
		die(4.0)
		return

	# If the boss is holding position, getting hit should trigger the counter attack
	# and then force a move to a new random point on the radius.
	if waiting_for_player_hit:
		waiting_for_player_hit = false
		has_orbit_target = false
		move_attack_used = false
		move_attack_in_progress = true
		must_leave_hold_position = true
		ranged_attack_in_progress = false

		_change_state("Hit")
		await get_tree().create_timer(0.5).timeout
		if is_dead: return

		_change_state("Melee01")
		await get_tree().create_timer(1.0).timeout
		if is_dead: return

		move_attack_in_progress = false
		_pick_new_orbit_target(true)
		_change_state("Move")
		return

	# Standard hit reaction while the boss is still travelling.
	_change_state("Hit")
	await get_tree().create_timer(0.5).timeout
	if is_dead: return

	_change_state("Move")

func _handle_move_logic(delta, _dist_to_player):
	if not is_instance_valid(player): return
	if move_attack_in_progress: return
	
	if not has_orbit_target:
		_pick_new_orbit_target()

	var dist_to_player = global_position.distance_to(player.global_position)

	if not move_attack_used and dist_to_player <= ATTACK_RANGE:
		move_attack_used = true
		_play_move_attack_once()
		return

	var dist_to_target = global_position.distance_to(orbit_target)
	var dist_from_hold_position = global_position.distance_to(hold_position)

	nav_agent.set_target_position(orbit_target)
	var next_pos = nav_agent.get_next_path_position()
	var move_dir = next_pos - global_position
	move_dir.y = 0.0
	if move_dir.length() < 0.1 and dist_to_target > RADIUS_TOLERANCE:
		move_dir = orbit_target - global_position
		move_dir.y = 0.0

	if must_leave_hold_position and dist_from_hold_position >= LEAVE_HOLD_DISTANCE:
		must_leave_hold_position = false

	var path_arrived = (nav_agent.is_navigation_finished() or move_dir.length() < 0.1) and not must_leave_hold_position

	if dist_to_target <= RADIUS_TOLERANCE or path_arrived:
		velocity = Vector3.ZERO
		hold_position = global_position
		waiting_for_player_hit = true
		must_leave_hold_position = false
		_change_state("Ranged")
		_start_ranged_attack()
		return

	velocity = move_dir.normalized() * SPEED
	_face_target(delta)

func _hold_ranged_position(delta):
	velocity = Vector3.ZERO
	global_position.x = hold_position.x
	global_position.z = hold_position.z
	if is_instance_valid(player):
		_face_target(delta)

	if state_machine.get_current_node() != "Ranged":
		_change_state("Ranged")

func _start_ranged_attack():
	if ranged_attack_in_progress or is_dead or not waiting_for_player_hit:
		return

	ranged_attack_in_progress = true
	_ranged_attack_loop()

func _ranged_attack_loop():
	await get_tree().create_timer(RANGED_SHOT_DELAY).timeout

	while not is_dead and waiting_for_player_hit:
		_fire_ranged_attack()

		if is_dead or not waiting_for_player_hit:
			break

		await get_tree().create_timer(RANGED_SHOT_INTERVAL).timeout

	ranged_attack_in_progress = false

func _fire_ranged_attack():
	if is_dead or not waiting_for_player_hit:
		return

	if not is_instance_valid(player):
		return

	var projectile = WIND_PROJECTILE_SCENE.instantiate()
	if projectile == null:
		return

	var spawn_origin = global_position + Vector3.UP * 1.5

	if is_instance_valid(projectile_spawn_point):
		
		spawn_origin = projectile_spawn_point.global_position

	projectile.global_position = spawn_origin

	var target_position = player.global_position + Vector3.UP * PLAYER_AIM_HEIGHT
	var shot_direction = target_position - spawn_origin
	if shot_direction.length() < 0.1:
		shot_direction = -global_transform.basis.z

	if projectile.has_method("set_direction"):
		projectile.set_direction(shot_direction.normalized())
	else:
		projectile.look_at(spawn_origin + shot_direction.normalized(), Vector3.UP)

	var current_scene = get_tree().current_scene
	if current_scene == null:
		projectile.queue_free()
		return

	current_scene.add_child(projectile)

func _pick_new_orbit_target(force_far_side := false):
	if not is_instance_valid(player):
		return

	var candidate_target = global_position
	var found_valid_target = false

	for i in range(8):
		var random_angle = randf_range(0.0, TAU)
		if force_far_side:
			var dir_from_player = global_position - player.global_position
			if dir_from_player.length() < 0.1:
				dir_from_player = Vector3.FORWARD
			random_angle = atan2(-dir_from_player.z, -dir_from_player.x) + randf_range(-PI / 3.0, PI / 3.0)

		var offset = Vector3(cos(random_angle), 0.0, sin(random_angle)) * TARGET_RADIUS
		candidate_target = player.global_position + offset
		candidate_target.y = global_position.y

		if global_position.distance_to(candidate_target) >= MIN_REPOSITION_DISTANCE:
			found_valid_target = true
			break

	if not found_valid_target:
		var fallback_dir = (global_position - player.global_position).normalized()
		if fallback_dir.length() < 0.1:
			fallback_dir = Vector3.FORWARD
		candidate_target = player.global_position - (fallback_dir * TARGET_RADIUS)
		candidate_target.y = global_position.y

	orbit_target = candidate_target
	orbit_target.y = global_position.y
	has_orbit_target = true
	waiting_for_player_hit = false
	move_attack_used = false

func _play_move_attack_once():
	if move_attack_in_progress or is_dead:
		return

	move_attack_in_progress = true
	velocity = Vector3.ZERO
	_change_state("Melee01")

	await get_tree().create_timer(1.0).timeout
	if is_dead:
		return

	move_attack_in_progress = false
	_change_state("Move")

func _face_target(delta):
	if is_instance_valid(player):
		var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		if global_position.distance_to(look_target) > 0.5:
			var new_transform = transform.looking_at(look_target, Vector3.UP)
			transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)

func _hit_player():
	if _target_in_range(1.0):
		player._hit(DMG)

func die(delay: float):
	died.emit()
	$CollisionShape3D.set_deferred("disabled", true)
	await get_tree().create_timer(delay).timeout
	queue_free()

func _target_in_range(add : float) -> bool:
	return global_position.distance_to(player.global_position) <= ATTACK_RANGE + add
