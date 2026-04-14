extends Node3D

@onready var interact:= $"../Player/Head/Camera3D/Interact"
@export var weapon_type : String
@onready var player: CharacterBody3D = $"../Player"
@onready var weapon: Node3D = $weapon


var can_pick_up_item = false
var changed = false

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and can_pick_up_item:
		match weapon_type:
			"dagger":
				player.player_data.u_dagger = true
			"shortSword":
				player.player_data.u_short_swort = true
			"mace":
				player.player_data.u_dmace = true
			"longSword":
				player.player_data.u_long_sword = true
			"poleHammer":
				player.player_data.u_pole_hammer = true
		player._weapon_out(weapon_type)
		weapon.hide()
		can_pick_up_item = false
		

func _process(_delta: float) -> void:
	if changed:
		changed = false
		if can_pick_up_item = 

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		can_pick_up_item = true
		changed = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		can_pick_up_item = false
		changed = true
