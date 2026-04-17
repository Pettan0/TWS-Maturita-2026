extends CharacterBody3D
signal died

@onready var player: CharacterBody3D = $"../Player"
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var animation_tree: AnimationTree = $AnimationTree
@export var area : Area3D
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
@onready var level: Node3D = $".."
@onready var sfx: AudioStreamPlayer3D = $SFX
@onready var hit_sfx: AudioStreamPlayer3D = $HitSFX
@onready var hp_bar: Sprite3D = $Sprite3D

var state_machine

var base_hp = 670
var player_level_scale = 10

var ATTACK_RANGE = 1.5
var DMG = 15.0
const SPEED = 5.0

var attack_cooldown := 2.0
var can_attack := true

var max_hp
var HP

var desired_distance := 20.0
var distance_tolerance := 2.0

var is_dead = false

var save_file_path = "user://save/"
var save_file_name = "SettingsData.tres"

var settingsData : SettingsData

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

func hit (damage_taken:float, _weapon_type:String, _dir:Vector3):
	HP -= damage_taken
	play_hit_sound()
	progress_bar.update_hp(max_hp, HP)
	if (HP <= 0):
		animation_tree.set("parameters/conditions/Death",true)
	else:
		animation_tree.set("parameters/conditions/Hit", true)

func _ready() -> void:
	load_data()
	hp_bar.visible = settingsData.enemy_hp_bar
	max_hp = player.player_data.difficulty_scale * (base_hp + (player.player_data.player_level - 1) * player_level_scale)
	DMG = DMG * player.player_data.difficulty_scale
	HP = max_hp
	progress_bar.update_hp(max_hp, HP)
	state_machine = animation_tree.get("parameters/playback")

func _physics_process(_delta):
	match state_machine.get_current_node():
		"Idle":
			pass
		"Move":
			pass
		"Melee01":
			pass
		"Hit":
			pass
		"Death":
			pass

func handle_positioning(_delta):
	var distance = global_position.distance_to(player.global_position)
	
	var direction = (player.global_position - global_position).normalized()
	
	if distance < desired_distance - distance_tolerance:
		velocity = -direction * SPEED
	
	elif distance > desired_distance + distance_tolerance:
		velocity = direction * SPEED
	
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()
	look_at(player.global_position)

#func try_attack():
	#var distance = global_position.distance_to(player.global_position)
	
	#if distance <= desired_distance + distance_tolerance and can_attack:
		#can_attack = false
		
		
		#shoot_projectile()
		
		#await get_tree().create_timer(attack_cooldown).timeout
		#can_attack = true
		#current_state = State.POSITIONING

func die(delay: float):
	died.emit()
	$CollisionShape3D.disabled = true
	await get_tree().create_timer(delay).timeout
	queue_free()

func play_attack_sound():
	sfx.stream = load("res://Assets/Sounds/SFX/Enemies/Knight/RytirAttack"+str(randi_range(1,4))+".wav")
	sfx.play()

func play_hit_sound():
	hit_sfx.stream = load("res://Assets/Sounds/SFX/Enemies/Knight/RytirDamaged"+str(randi_range(1,4))+".wav")
	hit_sfx.play()

func play_death_sound():
	sfx.stream = load("res://Assets/Sounds/SFX/Enemies/Knight/RytirDeath"+str(randi_range(1,3))+".wav")
	sfx.play()

func _hit_player():
	if _target_in_range(1):
		player._hit(DMG)
		
func _target_in_range(value: int) -> bool:
	return global_position.distance_to(player.global_position) <= ATTACK_RANGE + value
