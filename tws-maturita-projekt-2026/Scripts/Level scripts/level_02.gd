extends Node3D
@onready var interact: Label = $Player/Head/Camera3D/Interact

var next_lvl_id = 0

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and interact.visible:
		match next_lvl_id:
			0:
				pass
			1:
				$Player/Transition.visible = true
				$Player/Transition/AnimationPlayer.play("Fade_in")
				await  get_tree().create_timer(1.0).timeout
				get_tree().change_scene_to_file("res://Levels/Level01.scn")
			3:
				$Player/Transition.visible = true
				$Player/Transition/AnimationPlayer.play("Fade_in")
				await  get_tree().create_timer(1.0).timeout
				get_tree().change_scene_to_file("res://Levels/Level03.scn")

func _on_exit_door_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		interact.visible = true
		next_lvl_id = 1


func _on_exit_door_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		interact.visible = false
		next_lvl_id = 0

func _on_lvl_3_door_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		interact.visible = true
		next_lvl_id = 3

func _on_lvl_3_door_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		interact.visible = false
		next_lvl_id = 0
