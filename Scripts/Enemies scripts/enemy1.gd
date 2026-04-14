extends CharacterBody3D

@onready var player: CharacterBody3D = $"../Player"
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var animation_tree: AnimationTree = $AnimationTree
@export var area : Area3D
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
@onready var blood_particles: GPUParticles3D = $Impact_Blood/BloodParticles
@onready var sfx: AudioStreamPlayer3D = $SFX
@onready var bes_1: MeshInstance3D = $Armature/Skeleton3D/Bes1
@onready var bes_2: MeshInstance3D = $Armature/Skeleton3D/Bes2

var state_machine

const max_hp = 100.0
var HP = max_hp
var ATTACK_RANGE = 1.5
var DMG = 2.0
const SPEED = 2.0


func hit (damage_taken:float, weapon_type:String, dir:Vector3):
	if weapon_type == "dagger" or weapon_type == "shortSword" or weapon_type == "longSword":
		blood_particles.trigger(dir)
	HP -= damage_taken
	progress_bar.update_hp(max_hp, HP)
	play_hit_sound()
	if (HP <= 0):
		animation_tree.set("parameters/conditions/Death"+str(randi_range(1,3)),true)

func _ready() -> void:
	progress_bar.update_hp(max_hp, HP)
	state_machine = animation_tree.get("parameters/playback")
func _physics_process(_delta):
	match state_machine.get_current_node():
		"Idle":
			animation_tree.set("parameters/conditions/Move",area._is_player_in_area())
		"Move":
			velocity = Vector3.ZERO
			nav_agent.set_target_position(player.global_position)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_position).normalized() * SPEED
			look_at(Vector3(next_nav_point.x, global_position.y, next_nav_point.z), Vector3.UP)
			animation_tree.set("parameters/conditions/Attack",_target_in_range())
			
			move_and_slide()
			animation_tree.set("parameters/conditions/Idle",!area._is_player_in_area())
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			animation_tree.set("parameters/conditions/Idle",!_target_in_range())
		"Death01":
			$CollisionShape3D.disabled = true
			await get_tree().create_timer(3.0).timeout
			self.free()
		"Death02":
			$CollisionShape3D.disabled = true
			await get_tree().create_timer(3.0).timeout
			self.free()
		"Death03":
			$CollisionShape3D.disabled = true
			await get_tree().create_timer(3.0).timeout
			self.free()

func play_attack_sound():
	sfx.stream = load("res://Assets/Sounds/SFX/Enemies/bes/Bes - attack "+str(randi_range(1,4))+".wav")
	sfx.pitch_scale = randf_range(.8, 1.2)
	sfx.play()

func play_hit_sound():
	sfx.stream = load("res://Assets/Sounds/SFX/Enemies/bes/Bes - damaged "+str(randi_range(1,4))+".wav")
	sfx.pitch_scale = randf_range(.8, 1.2)
	sfx.play()

func play_death_sound():
	sfx.stream = load("res://Assets/Sounds/SFX/Enemies/bes/Bes - death"+str(randi_range(1,4))+ ".wav")
	sfx.pitch_scale = randf_range(.8, 1.2)
	sfx.play()

func _hit_player():
	if _target_in_range():
		player._hit(DMG)
func _target_in_range() -> bool:
	return global_position.distance_to(player.global_position) <= ATTACK_RANGE
