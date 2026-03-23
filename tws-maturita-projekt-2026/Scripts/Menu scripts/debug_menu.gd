extends Panel


func _on_button_level_test_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/LevelTest.tscn")

func _on_button_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level01.scn")
	
func _on_button_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level02.scn")

func _on_button_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level03.scn")

func _on_button_back_pressed() -> void:
	hide()
