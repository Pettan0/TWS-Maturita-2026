extends Node3D
@onready var sfx: AudioStreamPlayer3D = $SFX
@onready var crate: Node3D = $".."
@onready var crate_root: Node3D = $"../.."
@export var hp : float

func hit(damage, _a, _b):
	print("hit" + str(damage))
	hp -= damage
	if hp > 0:
		sfx.stream = load("res://Assets/Sounds/SFX/Ostatní/CrateHit"+str(randi_range(1,3))+".wav")
		sfx.pitch_scale = randf_range(.8, 1.2)
		sfx.play()
	else :
		SoundManager.play_crate_sfx()
		if $"../../..".has_method("spawn_item"):
			$"../../..".spawn_item()
		crate.queue_free()
	print(hp)
