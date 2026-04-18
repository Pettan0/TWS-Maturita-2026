extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hi := $Hi
@onready var player: CharacterBody3D = $"../Player"
@onready var dialog: AudioStreamPlayer = $Dialog

var state_machine

func _ready() -> void:
	state_machine = animation_tree.get("parameters/playback")
	

func _process(_delta: float) -> void:
	match state_machine.get_current_node():
		"Idle":
			pass
		"cauHynku2":
			pass
		"cauHynku3":
			pass
		"cauHynku4":
			pass
		"Idle 2":
			pass
	
	#diaog
		"Idle 6":
			pass
		"Talk01":
			pass
		"Idle 3":
			pass
		"Talk02":
			pass
		"Idle 4":
			pass
		"Talk03":
			pass
	
	#konec dialogu
		"Idle 5":
			pass

func play_hi2():
	hi.stream = load("res://Assets/Sounds/Dub/cawHynku2.wav")
	hi.play()

func play_hi3():
	hi.stream = load("res://Assets/Sounds/Dub/cawHynku3.wav")
	hi.play()

func play_hi4():
	hi.stream = load("res://Assets/Sounds/Dub/cawHynku4.wav")
	hi.play()
func say_hi():
	if player.player_data.deaths <= 0:
		animation_tree.set("parameters/conditions/Hi3", true)
	else:
		var rand_num = randi_range(2, 4)
		animation_tree.set("parameters/conditions/Hi" + str(rand_num), true)

func start_talk():
	dialog.play()
	animation_tree.set("parameters/conditions/StartTalking", true)
	await get_tree().create_timer(1.7).timeout
	animation_tree.set("parameters/conditions/Talk1", true)
	await get_tree().create_timer(18.4).timeout
	animation_tree.set("parameters/conditions/Talk2", true)
	await get_tree().create_timer(7.6).timeout
	animation_tree.set("parameters/conditions/Talk3", true)
