extends Node3D
@onready var animation_tree: AnimationTree = $AnimationTree

var state_machine

func _ready() -> void:
	state_machine = animation_tree.get("parameters/playback")

func _physics_process(_delta):
	match state_machine.get_current_node():
		"Idle":
			pass
		"Move":
			animation_tree.set("parameters/conditions/Idle", true)
