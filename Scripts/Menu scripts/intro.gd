extends VideoStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().change_scene_to_file("res://Levels/Level01.scn")
	if Input.is_action_just_pressed("jump"):
		if paused:
			play()
		else:
			stop()


func _on_finished() -> void:
	pass # Replace with function body.
