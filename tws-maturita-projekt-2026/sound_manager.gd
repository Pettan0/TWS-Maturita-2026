extends Control
@onready var crate_sfx: AudioStreamPlayer = $CrateSFX
@onready var door_sxf: AudioStreamPlayer = $DoorSXF

func play_crate_sfx():
	crate_sfx.stream = load("res://Assets/Sounds/SFX/Ostatní/CrateBreak"+str(randi_range(1,3))+".wav")
	crate_sfx.pitch_scale = randf_range(.8, 1.2)
	crate_sfx.play()

func play_door_sfx():
	door_sxf.play()
