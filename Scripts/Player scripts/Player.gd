extends CharacterBody3D
@onready var head:= $Head
@onready var camera:= $Head/Camera3D

#menus
@onready var pause_menu:= $Head/Camera3D/PauseMenu
@onready var settings_menu:= $Head/Camera3D/PauseMenu/Settings
@onready var skill_tree:= $Head/Camera3D/SkillTree
@onready var transition: Control = $Transition
@onready var xp_bar: ProgressBar = $Head/Camera3D/xp_bar
@onready var hp_bar: ProgressBar = $Head/Camera3D/HpBar
@onready var stamina: ProgressBar = $Head/Camera3D/Stamina
@onready var popup: Label = $Head/Camera3D/Popup
@onready var player_level_label: Label = $Head/Camera3D/Label
@onready var stamina_overlay: Panel = $Head/Camera3D/StaminaOverlay
@onready var game_over: TextureRect = $Head/Camera3D/GameOver
@onready var hit_flash: Panel = $Head/Camera3D/HitFlash

#sxf
@onready var jump: AudioStreamPlayer = $Jump
@onready var attack: AudioStreamPlayer = $Attack
@onready var footstep: AudioStreamPlayer = $Footstep
@onready var damaga_taken: AudioStreamPlayer = $DamagaTaken
@onready var hit: AudioStreamPlayer = $Hit
@onready var sword_swing: AudioStreamPlayer = $SwordSwing
@onready var lvl_up: AudioStreamPlayer = $LvlUp
@onready var xp_bubble: AudioStreamPlayer = $XpBubble
@onready var death_sfx: AudioStreamPlayer = $Death

#weapons
@onready var unarmed:= $Head/unarmed
@onready var dagger:= $Head/dagger
@onready var short_sword: Node3D = $Head/shortsword
@onready var mace: Node3D = $Head/mace
@onready var long_sword: Node3D = $Head/longsword
@onready var pole_hammer: Node3D = $Head/poleHammer

@onready var headbob: AnimationPlayer = $Head/Headbob
@onready var fov_animation: AnimationPlayer = $Head/FovAnimation

@onready var unarmed_animations: AnimationPlayer = $Head/unarmed/AnimationPlayer
@onready var dagger_animations:AnimationPlayer = $Head/dagger/AnimationPlayer
@onready var short_sword_animations: AnimationPlayer = $Head/shortsword/AnimationPlayer
@onready var mace_animations: AnimationPlayer = $Head/mace/AnimationPlayer
@onready var long_sword_animations: AnimationPlayer = $Head/longsword/AnimationPlayer
@onready var pole_hammer_animations: AnimationPlayer = $Head/poleHammer/AnimationPlayer
@onready var leg_animation: AnimationPlayer = $Head/Leg/AnimationPlayer

var save_file_path = "user://save/"
var save_file_name = "PlayerData.tres"

var player_data : PlayerData
var skill_points = 0
var base_dmg = 0.0
var base_kick_dmg = 0.0

var code_time = 0
var code_progres = 0
var super_secred = false

var is_in_area = false
var attacking = false
var paused = false
var current_weapon = "unarmed"
var blocking = false

#maly vojta -> 🐒

var speed = 3.0
var jump_velocity = 3.1
var dead = false

#hp regen?
var can_hp_regen = false
var rtimer = 0.0
var can_start_rtimer = false

#Stamina veci
var can_s_regen = false
var stimer = 0
var can_start_stimer = true

var ktimer = 0


func _ready():
	load_data()
	create_tween().tween_property(game_over, "modulate:a", 0.0, 0.0).set_trans(Tween.TRANS_SINE)
	create_tween().tween_property(hit_flash, "modulate:a", 0.0, 0.0).set_trans(Tween.TRANS_SINE)
	long_sword.position = Vector3(0, -0.414, -0.621) #forced value bcs its broken
	
	#ziskavani promnen a nastavovani textu / progres baru
	base_dmg = player_data.base_dmg
	base_kick_dmg = player_data.kick_dmg
	skill_points = player_data.skill_points
	player_level_label.text = "Lvl: "+str(player_data.player_level)
	xp_bar.value = player_data.xp
	xp_bar.max_value = player_data.xp_to_next
	hp_bar.max_value = player_data.max_hp
	hp_bar.value = player_data.hp
	stamina.value = stamina.max_value
	fov_animation.speed_scale = 3
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	headbob.play("Headbob")
	_weapon_out(player_data.current_weapon)
	
	#zapne prechod
	transition.fade_out()

func died():
	create_tween().tween_property(game_over, "modulate:a", 0.9, 0.5).set_trans(Tween.TRANS_SINE)

#lodeni a ukladani player data
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
	
	create_tween().tween_property(stamina_overlay, "modulate:a", clamp((20.0 - stamina.value) / 20.0, 0.0, 0.8), 0.1).set_trans(Tween.TRANS_SINE)
	
	# code vec
	if code_time > 0:
		code_time  -=  delta
		if code_time < 0:
			print("Proggress lost :(")
			code_progres = 0
	
	stamina.max_value = player_data.max_stamina
	
	if ktimer > 0:
		ktimer -= delta
	
	
	#udatne staty podle data hrace
	hp_bar.value = player_data.hp
	base_dmg = player_data.base_dmg
	skill_points = player_data.skill_points
	
	#Stamina veci
	if !can_s_regen and stamina.value != player_data.max_stamina or stamina.value == 0:
		can_start_stimer = true
		if can_start_stimer:
			stimer += delta
			if stimer >= player_data.stime_to_wait:
				can_s_regen = true
				can_start_stimer = false
				stimer = 0
	if stamina.value == player_data.max_stamina:
		can_s_regen = false
	if can_s_regen:
		stamina.value += player_data.sregen
		can_start_stimer = true
		stimer = 0
	
	#hp regen
	if !can_hp_regen and player_data.hp <= player_data.max_hp:
		can_start_rtimer =  true
		if can_start_rtimer:
			rtimer += delta
			if rtimer >= player_data.rtimer_to_wait:
				can_hp_regen = true
				can_start_rtimer = false
				rtimer = 0
	if can_hp_regen and player_data.u_hp_regen:
		if player_data.hp + player_data.r_per_time < player_data.max_hp:
			player_data.hp += player_data.r_per_time
		else:
			player_data.hp = player_data.max_hp
		can_start_rtimer = true
		can_hp_regen = false
		rtimer = 0


#ukaže jednotlivé menu
func _pauseMenu():
	velocity = Vector3.ZERO
	headbob.stop()
	if paused:
		pause_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		pause_menu.show()
		settings_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	paused = !paused
func _skill_tree():
	velocity = Vector3.ZERO
	headbob.stop()
	if paused:
		skill_tree.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		skill_tree.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	paused = !paused

#hrani jednotlivich random sxf
func _play_attack_sound():
	$Attack.stream = load("res://Assets/Sounds/SFX/Player/New SFX/combat0"+str(randi_range(1,7))+".mp3")
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

#funkce pro vytazeni zbrane + if je odemcena
func _weapon_out(type:String):
	save_data()
	match type:
		"unarmed":
			unarmed.show()
			dagger.hide()
			short_sword.hide()
			mace.hide()
			long_sword.hide()
			pole_hammer.hide()
			current_weapon = "unarmed"
			player_data.current_weapon = current_weapon
		"dagger":
			if player_data.u_dagger:
				dagger.show()
				unarmed.hide()
				short_sword.hide()
				mace.hide()
				long_sword.hide()
				pole_hammer.hide()
				current_weapon = "dagger"
				player_data.current_weapon = current_weapon
			else :
				popup.show_with("lockedWeapon")
		"shortSword":
			if player_data.u_short_sword:
				short_sword.show()
				unarmed.hide()
				dagger.hide()
				mace.hide()
				long_sword.hide()
				pole_hammer.hide()
				current_weapon = "shortSword"
				player_data.current_weapon = current_weapon
			else :
				popup.show_with("lockedWeapon")
		"mace":
			if player_data.u_mace:
				mace.show()
				unarmed.hide()
				dagger.hide()
				short_sword.hide()
				long_sword.hide()
				pole_hammer.hide()
				current_weapon = "mace"
				player_data.current_weapon = current_weapon
			else :
				popup.show_with("lockedWeapon")
		"longSword":
			if player_data.u_long_sword:
				long_sword.show()
				unarmed.hide()
				dagger.hide()
				short_sword.hide()
				mace.hide()
				pole_hammer.hide()
				current_weapon = "longSword"
				player_data.current_weapon = current_weapon
			else :
				popup.show_with("lockedWeapon")
		"poleHammer":
			if player_data.u_pole_hammer:
				pole_hammer.show()
				unarmed.hide()
				dagger.hide()
				short_sword.hide()
				mace.hide()
				long_sword.hide()
				current_weapon = "poleHammer"
				player_data.current_weapon = current_weapon
			else :
				popup.show_with("lockedWeapon")

#pridani xp a lvl up
func add_xp(amount:float):
	if amount + player_data.xp < player_data.xp_to_next:
		player_data.xp += amount
		xp_bubble.play()
	else:
		player_data.new_xp_to_next(amount)
		lvl_up.play()
		player_level_label.text = "Lvl: "+str(player_data.player_level)
		player_data.hp = player_data.max_hp
	save_data()
	print("current xp: "+ str(player_data.xp))
	xp_bar.value = player_data.xp
	xp_bar.max_value = player_data.xp_to_next
	
	save_data()

#vsechny keybindy
func _unhandled_input(event: InputEvent) -> void:
	#easter egg
	if super_secred:
		if Input.is_action_pressed("w") and code_progres == 0:
			code_time = 5.0
			code_progres += 1 
		if Input.is_action_pressed("s") and code_progres == 1:
			code_time = 5.0
			code_progres += 1
			print("Proggress...")
		if Input.is_action_pressed("w") and code_progres == 2:
			code_time = 5.0
			code_progres += 1
			print("Proggress...")
		if Input.is_action_pressed("s") and code_progres == 3:
			code_time = 5.0
			code_progres += 1
			print("Proggress...")
		if Input.is_action_pressed("a") and code_progres == 4:
			code_time = 5.0
			code_progres += 1
			print("Proggress...")
		if Input.is_action_pressed("d") and code_progres == 5:
			code_time = 5.0
			code_progres += 1
			print("Proggress...")
		if Input.is_action_pressed("a") and code_progres == 6:
			code_time = 5.0
			code_progres += 1
			print("Proggress...")
		if Input.is_action_pressed("d") and code_progres == 7:
			code_time = 5.0
			code_progres += 1
			print("Proggress...")
		if Input.is_action_pressed("b") and code_progres == 8:
			code_time = 5.0
			code_progres += 1
			print("Proggress...")
		if Input.is_action_pressed("a") and code_progres == 9:
			code_time = 5.0
			code_progres += 1
			print("Proggress...")
		if Input.is_action_pressed("pause") and code_progres == 10:
			_pauseMenu()
			popup.show_custom("Dokázal jsi to :D")
			_hit(1000)
	if !paused and !dead:
		#zapnuti kodu
		if Input.is_action_just_pressed("secred"):
			super_secred = !super_secred
			if super_secred:
				popup.show_custom("Zapnul jsi super tajné nastavení na zadávání kodů :)")
			else:
				popup.show_custom("Vypnul jsi super tajné nastavení.")
			print("Super secret is "+str(super_secred))
		#keybind na zbrane
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
		#jednotlive bojove akce
		if Input.is_action_just_pressed("attack"):
			if !attacking and stamina.value > player_data.attack_stamina:
				attacking = true
				stamina.value -= player_data.attack_stamina
				can_s_regen = false
				stimer = 0
				#vybrani jedne zbrane
				match current_weapon:
					"unarmed":
						unarmed_animations.speed_scale = 1.0 * player_data.attack_speed
						unarmed_animations.play("Attack")
						await  get_tree().create_timer(1.0 / player_data.attack_speed).timeout
					"dagger":
						dagger_animations.speed_scale = 1.0 * player_data.attack_speed
						dagger_animations.play("Attack")
						await  get_tree().create_timer(1.0 / player_data.attack_speed).timeout
					"shortSword":
						short_sword_animations.speed_scale = 1.0 * player_data.attack_speed
						short_sword_animations.play("Attack")
						await  get_tree().create_timer(1.75 / player_data.attack_speed).timeout
					"mace":
						mace_animations.speed_scale = 1.0 * player_data.attack_speed
						mace_animations.play("Attack")
						await  get_tree().create_timer(1.4 / player_data.attack_speed).timeout
					"longSword":
						long_sword_animations.speed_scale = 1.0 * player_data.attack_speed
						long_sword_animations.play("Attack")
						await  get_tree().create_timer(1.5 / player_data.attack_speed).timeout
					"poleHammer":
						pole_hammer_animations.speed_scale = 1.0 * player_data.attack_speed
						pole_hammer_animations.play("Attack")
						await  get_tree().create_timer(2.2 / player_data.attack_speed).timeout
				attacking = false
			elif stamina.value < player_data.attack_stamina and !attacking:
				popup.show_with("outOfStamina")
		if Input.is_action_just_pressed("block") :
			if player_data.can_block and !blocking and !attacking and stamina.value > 15:
				blocking = true
				stamina.value -= 15
				can_s_regen = false
				stimer = 0
				match current_weapon:
					"unarmed":
						unarmed_animations.speed_scale = 1.0
						unarmed_animations.play("Block")
					"dagger":
						dagger_animations.speed_scale = 1.0
						dagger_animations.play("Block")
					"shortSword":
						short_sword_animations.speed_scale = 1.0
						short_sword_animations.play("Block")
					"mace":
						mace_animations.speed_scale = 1.0
						mace_animations.play("Block")
					"longSword":
						long_sword_animations.speed_scale = 1.0
						long_sword_animations.play("Block")
					"poleHammer":
						pole_hammer_animations.speed_scale = 1.0
						pole_hammer_animations.play("Block")
				await  get_tree().create_timer(1.5).timeout
				blocking = false
			elif !player_data.can_block:
				popup.show_with("lockedAbility")
			elif stamina.value < 15 and !attacking and !blocking:
				popup.show_with("outOfStamina")
		if Input.is_action_just_pressed("kick"):
			if player_data.can_kick and ktimer <= 0 and !attacking and stamina.value >= 20:
				attacking = true
				stamina.value -= 20
				can_s_regen = false
				stimer = 0
				ktimer = player_data.kick_cooldown
				leg_animation.play("Kick")
				await get_tree().create_timer(1.25).timeout
				attacking = false
			elif player_data.can_kick and !attacking:
				popup.show_with("abilityOnCooldown")
			elif !attacking:
				popup.show_with("lockedAbility")
			elif stamina.value < 20 and !attacking:
				popup.show_with("outOfStamina")
		if Input.is_action_just_pressed("skillTree"):
			_skill_tree()
		if Input.is_action_just_pressed("pause"):
			_pauseMenu()
		#otaceni kamery 
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				rotate_y(-event.relative.x * 0.002)
				head.rotate_x(-event.relative.y * 0.002)
				head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	else:
		#kdyz ne pozastaveno schova but skill tree nebo pause menu
		if Input.is_action_just_pressed("pause"):
			if pause_menu.visible:
				pause_menu.hide()
			elif skill_tree.visible:
				skill_tree.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			paused = !paused
	#schovani ui
	if Input.is_action_just_pressed("f1"):
		if hp_bar.visible and stamina.visible:
			xp_bar.hide()
			hp_bar.hide()
			stamina.hide()
			player_level_label.hide()
		else:
			xp_bar.show()
			player_level_label.show()
			hp_bar.show()
			stamina.show()
	#debug tlacitko pro testovani ODSTANIT
	if Input.is_action_just_pressed("debug"):
		add_xp(100)

func hit_animation():
	create_tween().tween_property(hit_flash, "modulate:a", 1.0, 0.1).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(0.1).timeout
	create_tween().tween_property(hit_flash, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)

#dostavani dmg
func _hit(damage : float):
	if !dead:
		if !blocking:
			_play_damage_sound()
			player_data.hp -= damage
			save_data()
			hit_animation()
		else:
			_play_hit_sound()
			hit_animation()
			if player_data.block_dmg != 1.0:
				_play_damage_sound()
			player_data.hp -= damage * (player_data.block_dmg - 1 + 1)
			save_data()
	if player_data.hp <= 0:
		dead = true
		headbob.stop()
		fov_animation.stop()
		velocity = Vector3.ZERO
		death_sfx.play()
		$Head/HitAnimation.play("Death")
		await get_tree().create_timer(2.5).timeout
		player_data.hp = player_data.max_hp
		player_data.update_level_stats(1,1)
		save_data()
		get_tree().change_scene_to_file("res://Levels/Level01.scn")

func _physics_process(delta: float) -> void:
	#gravitace lol 🍎
	if not is_on_floor():
			velocity += get_gravity() * delta
	if !paused and !dead:
			#skok 🤓
			if Input.is_action_just_pressed("jump") and is_on_floor():
				if stamina.value > 15:
					stamina.value -= 15.0
					can_s_regen = false
					stimer = 0
					velocity.y = jump_velocity
					jump.play()
				elif stamina.value < 15:
					popup.show_with("outOfStamina")
			
			#controls pohybu
			var input_dir := Input.get_vector("a", "d", "w", "s")
			var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction:
				#beh 👨‍🦽
				if Input.is_action_pressed("sprint") and stamina.value > 0:
					stamina.value -= 0.5
					can_s_regen = false
					stimer = 0
					if !attacking and !blocking:
						match current_weapon:
							"unarmed":
								unarmed_animations.speed_scale = 1.0
								unarmed_animations.play("Run")
							"dagger":
								dagger_animations.speed_scale = 1.0
								dagger_animations.play("Run")
							"shortSword":
								short_sword_animations.speed_scale = 1.0
								short_sword_animations.play("Run")
							"mace":
								mace_animations.speed_scale = 1.0
								mace_animations.play("Run")
							"longSword":
								long_sword_animations.speed_scale = 1.0
								long_sword_animations.play("Run")
							"poleHammer":
								pole_hammer_animations.speed_scale = 1.0
								pole_hammer_animations.play("Run")
					if camera.fov == 75:
						fov_animation.play("FovOut")
					if headbob.speed_scale != 2.0:
						headbob.speed_scale = 2.0
					velocity.x = direction.x * 1.2 * speed
					velocity.z = direction.z * 1.2 * speed
					if stamina.value <= 0:
						popup.show_with("outOfStamina")
				else: 
					if !attacking and !blocking:
						match current_weapon:
							"unarmed":
								pole_hammer_animations.speed_scale = 1.0
								unarmed_animations.play("Idle")
							"dagger":
								dagger_animations.speed_scale = 1.0
								dagger_animations.play("Idle")
							"shortSword":
								short_sword_animations.speed_scale = 1.0
								short_sword_animations.play("Idle")
							"mace":
								mace_animations.speed_scale = 1.0
								mace_animations.play("Idle")
							"longSword":
								long_sword_animations.speed_scale = 1.0
								long_sword_animations.play("Idle")
							"poleHammer":
								pole_hammer_animations.speed_scale = 1.0
								pole_hammer_animations.play("Idle")
					if camera.fov == 85: 
						fov_animation.play("FovIn")
					if headbob.speed_scale != 1.0:
						headbob.speed_scale = 1.0
					velocity.x = direction.x * speed
					velocity.z = direction.z * speed
				
			else:
				if !attacking and !blocking:
					match current_weapon:
						"unarmed":
							pole_hammer_animations.speed_scale = 1.0
							unarmed_animations.play("Idle")
						"dagger":
							dagger_animations.speed_scale = 1.0
							dagger_animations.play("Idle")
						"shortSword":
							short_sword_animations.speed_scale = 1.0
							short_sword_animations.play("Idle")
						"mace":
							mace_animations.speed_scale = 1.0
							mace_animations.play("Idle")
						"longSword":
							long_sword_animations.speed_scale = 1.0
							long_sword_animations.play("Idle")
						"poleHammer":
							pole_hammer_animations.speed_scale = 1.0
							pole_hammer_animations.play("Idle")
				if camera.fov == 85: 
					fov_animation.play("FovIn")
				if headbob.speed_scale != 0.0:
					headbob.speed_scale = 0.0
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
