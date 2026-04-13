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

@export var area : Area3D

var state_machine

var base_hp = 25.0
var max_hp = 50.0
var HP = max_hp
var xp = max_hp
var ATTACK_RANGE = 2.0
var DMG = 15.0
const SPEED = 1.0
var knockback = 4.0
var knockedback = false
var knockback_timer = 0.0
var armor = 0.05
var is_dead = false


func hit (damage_taken:float, weapon_type:String, dir:Vector3):
	if weapon_type == "mace" or weapon_type == "poleHammer":
		HP -= damage_taken
	elif weapon_type == "kick":
		HP -= damage_taken*(1 - armor)

		var knock_dir = dir.normalized()
		velocity = knock_dir * knockback
		knockedback = true
		knockback_timer = 0.25
		animation_tree.set("parameters/conditions/Hit",true)

	else:
		HP -= damage_taken*(1 - armor)
	play_hit_sound()
	progress_bar.update_hp(max_hp, HP)
	if (HP <= 0):
		animation_tree.set("parameters/conditions/Death"+str(randi_range(1,3)),true)

func _ready() -> void:
	armor = min((player.player_data.player_level) * 0.05,0.75)
	max_hp = base_hp + (player.player_data.player_level - 1) * 10
	HP = max_hp
	progress_bar.update_hp(max_hp, HP)
	state_machine = animation_tree.get("parameters/playback")
	print("armor: "+str(armor))
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
	sfx.stream = load("res://Assets/Sounds/SFX/Enemies/Knight/RytirAttack"+str(randi_range(1,4))+".wav")
	sfx.play()

func play_hit_sound():
	hit_sfx.stream = load("res://Assets/Sounds/SFX/Enemies/Knight/RytirDamaged"+str(randi_range(1,4))+".wav")
	hit_sfx.play()

func play_death_sound():
	sfx.stream = load("res://Assets/Sounds/SFX/Enemies/Knight/RytirDeath"+str(randi_range(1,3))+".wav")
	sfx.play()

func _hit_player():
	if _target_in_range(1.0):
		player._hit(DMG)
func _target_in_range(add : float) -> bool:
	return global_position.distance_to(player.global_position) <= ATTACK_RANGE + add
