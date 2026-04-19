extends Control
@onready var crate_sfx: AudioStreamPlayer = $CrateSFX
@onready var door_sxf: AudioStreamPlayer = $DoorSXF
@onready var btn_hover: AudioStreamPlayer = $BtnHover
@onready var btn_click: AudioStreamPlayer = $BtnClick
@onready var upgrade_1: AudioStreamPlayer = $STUpgrade1
@onready var upgrade_2: AudioStreamPlayer = $STUpgrade2
@onready var zoomer: AudioStreamPlayer = $Zoomer

func play_crate_sfx():
	crate_sfx.stream = load("res://Assets/Sounds/SFX/Ostatní/CrateBreak"+str(randi_range(1,3))+".wav")
	crate_sfx.pitch_scale = randf_range(.8, 1.2)
	crate_sfx.play()

func play_door_sfx():
	door_sxf.play()

func play_btn_click_sfx():
	btn_click.stream = load("res://Assets/Sounds/SFX/Button/click"+str(randi_range(1,3))+".wav")
	btn_click.pitch_scale = randf_range(.8, 1.2)
	btn_click.play()

func play_btn_hover_sfx():
	btn_hover.play()
func upgrade_sfx(type:String):
	match type:
		"B":
			upgrade_1.play()
		"A":
			upgrade_2.play()

func zoomer_play():
	zoomer.pitch_scale = randf_range(.8, 1.2)
	zoomer.play()
