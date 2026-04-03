extends Panel

@onready var player:= $"../../.."


func _on_button_back_pressed() -> void:
	player._skill_tree()
