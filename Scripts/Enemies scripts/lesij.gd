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

var state_machine

var base_hp = 50
var player_level_scale = 5
var current_level_scale = 30

var ATTACK_RANGE = 1.5
var DMG = 15.0
const SPEED = 3.1

var knockback = 4.0
var knockedback = false
var knockback_timer = 0.0

var max_hp
var HP 
var xp
var attack_dir = Vector3.ZERO

var is_dead = false


func hit (damage_taken:float, weapon_type:String, dir:Vector3):
	if weapon_type == "kick":

		var knock_dir = dir.normalized()
		velocity = knock_dir * knockback
		knockedback = true
		knockback_timer = 0.25
	HP -= damage_taken
	play_hit_sound()
	progress_bar.update_hp(max_hp, HP)
	if (HP <= 0):
		animation_tree.set("parameters/conditions/Death"+str(randi_range(1,2)),true)

func _ready() -> void:
	max_hp = base_hp + (player.player_data.level - 2) * current_level_scale + (player.player_data.player_level - 1) * player_level_scale
	HP = max_hp
	xp = max_hp
	progress_bar.update_hp(max_hp, HP)
	state_machine = animation_tree.get("parameters/playback")

func _physics_process(delta):
	if knockedback:
		knockback_timer -= delta
		move_and_slide()

	if knockback_timer <= 0.0:
		knockedback = false
	match state_machine.get_current_node():
		"Idle":
			animation_tree.set("parameters/conditions/Move",area._is_player_in_area())
		"Move":
			var next_nav_point = nav_agent.get_next_path_position()
			nav_agent.set_target_position(player.global_position)
			attack_dir = (player.global_position - global_position)
			attack_dir.y = 0

			velocity = (next_nav_point - global_position).normalized() * SPEED

			look_at(Vector3(next_nav_point.x, global_position.y, next_nav_point.z), Vector3.UP)
			move_and_slide()
			animation_tree.set("parameters/conditions/Attack0" + str(randi_range(1,2)), _target_in_range(0))

			animation_tree.set("parameters/conditions/Idle", !area._is_player_in_area())
		"Attack01", "Attack02":
			if !_target_in_range(1):
				state_machine.travel("Move")
				return

			velocity = attack_dir * SPEED
			move_and_slide()
			
		"Death01":
			if !is_dead:
				is_dead = true
				die(3.0)
		"Death02":
			if !is_dead:
				is_dead = true
				die(4.0)

func die(delay: float):
	player.add_xp(xp)
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
