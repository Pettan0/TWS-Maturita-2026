extends CharacterBody3D
signal died

@onready var player: CharacterBody3D = $"../Player"
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar

@onready var level: Node3D = $".."

@onready var sfx: AudioStreamPlayer3D = $SFX
@onready var hit_sfx: AudioStreamPlayer3D = $HitSFX
@onready var blood_particles: GPUParticles3D = $Impact_Blood/BloodParticles

@onready var bes_1: MeshInstance3D = $Armature/Skeleton3D/Bes1
@onready var bes_2: MeshInstance3D = $Armature/Skeleton3D/Bes2

@export var area : Area3D

var state_machine
#nastavitelné proměny
var base_hp = 40
var player_level_scale = 5
var current_level_scale = 20
var ATTACK_RANGE = 1.5
var DMG = 10.0
const SPEED = 2.0
var knockback = 10.0

var max_hp : float
var HP : float
var xp : float

var knockedback = false
var knockback_timer = 0.0


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

func hit (damage_taken:float, weapon_type:String, dir:Vector3):
	if weapon_type == "dagger" or weapon_type == "shortSword" or weapon_type == "longSword":
		blood_particles.trigger(dir)
	elif weapon_type == "kick":
		var knock_dir = dir.normalized()
		knock_dir.y = 0
		velocity = knock_dir * knockback
		knockedback = true
		knockback_timer = 0.25

	HP -= damage_taken

	progress_bar.update_hp(max_hp, HP)
	if (HP <= 0):
		animation_tree.set("parameters/conditions/Death"+str(randi_range(1,3)),true)
	else: 
		animation_tree.set("parameters/conditions/Hit",true)

func _ready() -> void:
	load_data()
	progress_bar.visible = settingsData.enemy_hp_bar
	bes_1.hide()
	bes_2.hide()
	match randi_range(1,2):
		1:
			bes_1.show()
		2:
			bes_2.show()
	
	max_hp = player.player_data.difficulty_scale * (base_hp + (player.player_data.level - 2) * current_level_scale + (player.player_data.player_level - 1) * player_level_scale)
	DMG = DMG * player.player_data.difficulty_scale
	HP = max_hp
	xp = max_hp
	
	progress_bar.update_hp(max_hp, HP)
	state_machine = animation_tree.get("parameters/playback")
	print("hp: "+str(HP))

func _physics_process(_delta):
	if knockedback:
		knockback_timer -= _delta
		move_and_slide()

	if knockback_timer <= 0.0:
		knockedback = false
	match state_machine.get_current_node():
		"Idle":
			animation_tree.set("parameters/conditions/Move",area._is_player_in_area())
		"Move":
			velocity = Vector3.ZERO
			nav_agent.set_target_position(player.global_position)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_position).normalized() * SPEED
			look_at(Vector3(next_nav_point.x, global_position.y, next_nav_point.z), Vector3.UP)
			animation_tree.set("parameters/conditions/Attack",_target_in_range(0.0))
			
			move_and_slide()
			animation_tree.set("parameters/conditions/Idle",!area._is_player_in_area())
		"Hit":
			animation_tree.set("parameters/conditions/Hit",false)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			animation_tree.set("parameters/conditions/Idle",!_target_in_range(0.0))
		"Death01":
			if !is_dead:
				is_dead = true
				die(3.0)
		"Death02":
			if !is_dead:
				is_dead = true
				die(4.0)
		"Death03":
			if !is_dead:
				is_dead = true
				die(2.0)

func die(delay: float):
	player.add_xp(xp)
	died.emit()
	$CollisionShape3D.disabled = true
	await get_tree().create_timer(delay).timeout
	queue_free()

func play_attack_sound():
	sfx.stream = load("res://Assets/Sounds/SFX/Enemies/bes/Bes - attack "+str(randi_range(1,4))+".wav")
	sfx.pitch_scale = randf_range(.8, 1.2)
	sfx.play()

func play_hit_sound():
	hit_sfx.stream = load("res://Assets/Sounds/SFX/Enemies/bes/Bes - damaged "+str(randi_range(1,4))+".wav")
	hit_sfx.pitch_scale = randf_range(.8, 1.2)
	hit_sfx.play()

func play_death_sound():
	hit_sfx.stream = load("res://Assets/Sounds/SFX/Enemies/bes/Bes - death"+str(randi_range(1,4))+ ".wav")
	hit_sfx.pitch_scale = randf_range(.8, 1.2)
	hit_sfx.play()

func _hit_player():
	if _target_in_range(1.0):
		player._hit(DMG)
func _target_in_range(add : float) -> bool:
	return global_position.distance_to(player.global_position) <= ATTACK_RANGE + add
