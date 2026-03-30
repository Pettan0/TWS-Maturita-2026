extends Node3D

@onready var player: CharacterBody3D = $"../.."

@export var damage : float
@export var weapon_type : String

func _attack_sound():
	player._play_attack_sound()

func _sword_swing_sound():
	player._play_swing_sound()

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.has_method("hit") and visible:
		var hitbox_pos = $Armature/Skeleton3D/BoneAttachment3D/Hitbox.global_transform.origin
		var dir = (body.global_transform.origin - hitbox_pos).normalized()
		body.hit(damage, weapon_type, dir)
