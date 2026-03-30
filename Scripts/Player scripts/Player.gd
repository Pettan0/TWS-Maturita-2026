extends CharacterBody3D

@onready var head:= $Head
@onready var camera:= $Head/Camera3D
@onready var hp_bar: ProgressBar = $Head/Camera3D/HpBar
@onready var hp_label: Label = $Head/Camera3D/HpBar/Label
@onready var stamina: ProgressBar = $Head/Camera3D/Stamina
@onready var popup: Label = $Head/Camera3D/Popup



#menus
@onready var pause_menu:= $Head/Camera3D/PauseMenu
@onready var settings_menu:= $Head/Camera3D/PauseMenu/Settings
@onready var skill_tree:= $Head/Camera3D/SkillTree
@onready var transition: Control = $Transition

#sxf
@onready var jump: AudioStreamPlayer = $Jump
@onready var attack: AudioStreamPlayer = $Attack
@onready var footstep: AudioStreamPlayer = $Footstep
@onready var damaga_taken: AudioStreamPlayer = $DamagaTaken
@onready var hit: AudioStreamPlayer = $Hit
@onready var sword_swing: AudioStreamPlayer = $SwordSwing


#weapons
@onready var unarmed:= $Head/unarmed
@onready var dagger:= $Head/dagger
@onready var short_sword: Node3D = $Head/shortsword
@onready var mace: Node3D = $Head/mace
@onready var long_sword: Node3D = $Head/longsword
@onready var pole_hammer: Node3D = $Head/poleHammer

@onready var headbob: AnimationPlayer = $Head/Headbob
@onready var fov_animation: AnimationPlayer = $Head/FovAnimation
@onready var transition_anim: AnimationPlayer = $Transition/AnimationPlayer


@onready var unarmed_animations: AnimationPlayer = $Head/unarmed/AnimationPlayer
@onready var dagger_animations:AnimationPlayer = $Head/dagger/AnimationPlayer
@onready var short_sword_animations: AnimationPlayer = $Head/shortsword/AnimationPlayer
@onready var mace_animations: AnimationPlayer = $Head/mace/AnimationPlayer
@onready var long_sword_animations: AnimationPlayer = $Head/longsword/AnimationPlayer
@onready var pole_hammer_animations: AnimationPlayer = $Head/poleHammer/AnimationPlayer

var save_file_path = "user://save/"
var save_file_name = "PlayerData.tres"

var player_data : PlayerData


var is_in_area = false
var attacking = false
var paused = false
var current_weapon = "unarmed"
var blocking = false

var speed = 4.4
var jump_velocity = 3.1

#hp regen?
var can_hp_regen = false
var rtimer = 0.0
var can_start_rtimer = false

#Stamina veci
var stamina_regen = 0.38 #/mil s?
var can_s_regen = false
var stime_to_wait = 1.8
var stimer = 0
var can_start_stimer = true


func _ready():
	load_data()
	long_sword.position = Vector3(0, -0.414, -0.621)
	hp_bar.max_value = player_data.max_hp
	hp_bar.value = player_data.hp
	hp_label.text = str(player_data.hp)+" / "+ str(player_data.max_hp)
	stamina.value = stamina.max_value
	fov_animation.speed_scale = 3
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	headbob.play("Headbob")
	_weapon_out(player_data.current_weapon)
	
	transition.visible = true
	transition_anim.play("Fade_out")
	await  get_tree().create_timer(1.0).timeout
	transition.visible = false 


func load_data():
	if not DirAccess.dir_exists_absolute(save_file_path):
		DirAccess.make_dir_recursive_absolute(save_file_path)

	if FileAccess.file_exists(save_file_path + save_file_name):
		player_data = ResourceLoader.load(save_file_path + save_file_name)

	if player_data == null:
		player_data = PlayerData.new()
		save_data()

func save_data():
	ResourceSaver.save(player_data, save_file_path + save_file_name)
func _process(delta: float) -> void:
	hp_bar.value = player_data.hp
	hp_label.text = str(player_data.hp)+" / "+ str(player_data.max_hp)
	
	#Stamina veci
	if !can_s_regen and stamina.value != stamina.max_value or stamina.value == 0:
		can_start_stimer = true
		if can_start_stimer:
			stimer += delta
			if stimer >= stime_to_wait:
				can_s_regen = true
				can_start_stimer = false
				stimer = 0
	if stamina.value == stamina.max_value:
		can_s_regen = false
	if can_s_regen:
		stamina.value += stamina_regen
		can_start_stimer = true
		stimer = 0
	
	#hp regen
	if !can_hp_regen and player_data.hp != player_data.max_hp:
		can_start_rtimer =  true
		if can_start_rtimer:
			rtimer += delta
			if rtimer >= player_data.rtimer_to_wait:
				can_hp_regen = true
				can_start_rtimer = false
				rtimer = 0

	if can_hp_regen:
		player_data.hp += player_data.regen_per_time
		can_start_rtimer = true
		can_hp_regen = false
		rtimer = 0

func _pauseMenu():
	if paused:
		pause_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		pause_menu.show()
		settings_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	paused = !paused

func _skill_tree():
	if paused:
		skill_tree.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		skill_tree.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	paused = !paused
func _play_attack_sound():
	attack.stream = load("res://Assets/Sounds/SFX/Player/Attack"+str(randi_range(1,3))+".wav")
	attack.play()
func _play_damage_sound():
	damaga_taken.stream = load("res://Assets/Sounds/SFX/Player/DamageTaken"+str(randi_range(1,4))+".wav")
	damaga_taken.play()
func _play_footstep_sound():
	if is_on_floor():
		footstep.stream = load("res://Assets/Sounds/SFX/Player/Footstep"+str(randi_range(1,3))+".wav")
		footstep.pitch_scale = randf_range(.8, 1.2)
		footstep.play()
func _play_hit_sound():
	hit.stream = load("res://Assets/Sounds/SFX/Player/Hit"+str(randi_range(1,5))+".wav")
	hit.pitch_scale = randf_range(.8, 1.2)
	hit.play()
func _play_swing_sound():
	sword_swing.stream = load("res://Assets/Sounds/SFX/Player/SwordSwing"+str(randi_range(1,5))+".wav")
	sword_swing.play()

func _weapon_out(type:String):
	unarmed.hide()
	dagger.hide()
	short_sword.hide()
	mace.hide()
	long_sword.hide()
	pole_hammer.hide()
	match type:
		"unarmed":
			unarmed.show()
			current_weapon = "unarmed"
		"dagger":
			if player_data.u_dagger:
				dagger.show()
				current_weapon = "dagger"
				player_data.current_weapon = current_weapon
			else :
				popup.show_with("lockedWeapon")
		"shortSword":
			if player_data.u_short_swort:
				short_sword.show()
				current_weapon = "shortSword"
				player_data.current_weapon = current_weapon
			else :
				popup.show_with("lockedWeapon")
		"mace":
			if player_data.u_mace:
				mace.show()
				current_weapon = "mace"
				player_data.current_weapon = current_weapon
			else :
				popup.show_with("lockedWeapon")
		"longSword":
			if player_data.u_long_sword:
				long_sword.show()
				current_weapon = "longSword"
				player_data.current_weapon = current_weapon
			else :
				popup.show_with("lockedWeapon")
		"poleHammer":
			if player_data.u_pole_hammer:
				pole_hammer.show()
				current_weapon = "poleHammer"
				player_data.current_weapon = current_weapon
			else :
				popup.show_with("lockedWeapon")
func _unhandled_input(event: InputEvent) -> void:
	if !paused:
		if Input.is_action_just_pressed("wp1"):
			_weapon_out("unarmed")
		if Input.is_action_just_pressed("wp2"):
			_weapon_out("dagger")
		if Input.is_action_just_pressed("wp3"):
			_weapon_out("shortSword")
		if Input.is_action_just_pressed("wp4"):
			_weapon_out("mace")
		if Input.is_action_just_pressed("wp5"):
			_weapon_out("longSword")
		if Input.is_action_just_pressed("wp6"):
			_weapon_out("poleHammer")
		if Input.is_action_just_pressed("attack"):
			if !attacking and stamina.value > 10:
				attacking = true
				stamina.value -= 10
				can_s_regen = false
				stimer = 0
				match current_weapon:
					"unarmed":
						unarmed_animations.play("Attack")
						await  get_tree().create_timer(1.0).timeout
					"dagger":
						dagger_animations.play("Attack")
						await  get_tree().create_timer(1.0).timeout
					"shortSword":
						short_sword_animations.play("Attack")
						await  get_tree().create_timer(1.75).timeout
					"mace":
						mace_animations.play("Attack")
						await  get_tree().create_timer(1.4).timeout
					"longSword":
						long_sword_animations.play("Attack")
						await  get_tree().create_timer(1.5).timeout
					"poleHammer":
						pole_hammer_animations.play("Attack")
						await  get_tree().create_timer(2.2).timeout
				attacking = false
		if Input.is_action_just_pressed("block"):
			if !blocking and !attacking:
				blocking = true
				match current_weapon:
					"unarmed":
						unarmed_animations.play("Block")
					"dagger":
						dagger_animations.play("Block")
					"shortSword":
						short_sword_animations.play("Block")
					"mace":
						mace_animations.play("Block")
					"longSword":
						long_sword_animations.play("Block")
					"poleHammer":
						pole_hammer_animations.play("Block")
				await  get_tree().create_timer(1.5).timeout
				blocking = false
		if Input.is_action_just_pressed("skillTree"):
			_skill_tree()
		if Input.is_action_just_pressed("pause"):
			_pauseMenu()
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				rotate_y(-event.relative.x * 0.002)
				head.rotate_x(-event.relative.y * 0.002)
				head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	else:
		if Input.is_action_just_pressed("pause"):
			if pause_menu.visible:
				pause_menu.hide()
			elif skill_tree.visible:
				skill_tree.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			paused = !paused
	if Input.is_action_just_pressed("f1"):
		if hp_bar.visible and stamina.visible:
			hp_bar.hide()
			stamina.hide()
		else:
			hp_bar.show()
			stamina.show()
func _hit(damage : float):
	if !blocking:
		_play_damage_sound()
		player_data.hp -= damage
		save_data()
		if player_data.hp <= 0:
			pass
	else:
		_play_hit_sound()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if !paused:
		if Input.is_action_just_pressed("jump") and is_on_floor() and stamina.value > 15:
			stamina.value -= 15.0
			can_s_regen = false
			stimer = 0
			velocity.y = jump_velocity
			jump.play()
	
		var input_dir := Input.get_vector("a", "d", "w", "s")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			if Input.is_action_pressed("sprint") and stamina.value > 0:
				stamina.value -= 0.5
				can_s_regen = false
				stimer = 0
				if !attacking and !blocking:
					match current_weapon:
						"unarmed":
							unarmed_animations.play("Run")
						"dagger":
							dagger_animations.play("Run")
						"shortSword":
							short_sword_animations.play("Run")
						"mace":
							mace_animations.play("Run")
						"longSword":
							long_sword_animations.play("Run")
						"poleHammer":
							pole_hammer_animations.play("Run")
				if camera.fov == 75:
					fov_animation.play("FovOut")
				if headbob.speed_scale != 3.0:
					headbob.speed_scale = 3.0
				velocity.x = direction.x * 1.2 * speed
				velocity.z = direction.z * 1.2 * speed
			else: 
				if !attacking and !blocking:
					match current_weapon:
						"unarmed":
							unarmed_animations.play("Idle")
						"dagger":
							dagger_animations.play("Idle")
						"shortSword":
							short_sword_animations.play("Idle")
						"mace":
							mace_animations.play("Idle")
						"longSword":
							long_sword_animations.play("Idle")
						"poleHammer":
							pole_hammer_animations.play("Idle")
				if camera.fov == 85: 
					fov_animation.play("FovIn")
				if headbob.speed_scale != 1.5:
					headbob.speed_scale = 1.5
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			
		else:
			if !attacking and !blocking:
				match current_weapon:
					"unarmed":
						unarmed_animations.play("Idle")
					"dagger":
						dagger_animations.play("Idle")
					"shortSword":
							short_sword_animations.play("Idle")
					"mace":
						mace_animations.play("Idle")
					"longSword":
						long_sword_animations.play("Idle")
					"poleHammer":
							pole_hammer_animations.play("Idle")
			if camera.fov == 85: 
				fov_animation.play("FovIn")
			if headbob.speed_scale != 0.0:
				headbob.speed_scale = 0.0
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
