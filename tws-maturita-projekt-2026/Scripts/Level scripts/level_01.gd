extends Node3D
@onready var interact:= $Player/Head/Camera3D/Interact
@onready var area: Area3D = $Area
@onready var npc: AnimationTree = $Npc/AnimationTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and interact.visible:
		$Player/Transition.visible = true
		$Player/Transition/AnimationPlayer.play("Fade_in")
		await  get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Levels/Level02.scn")

func _on_door_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		interact.visible = true


func _on_door_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		interact.visible = false


func _on_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		npc.set("parameters/conditions/Hello",true)
