extends Panel

@onready var player:= $"../../.."
@onready var skill_points_label: Label = $Label

func _ready() -> void:
	skill_points_label.text = "sp: " + str(player.skill_points)

func _on_button_back_pressed() -> void:
	player._skill_tree()

func _process(_delta: float) -> void:
	skill_points_label.text = "sp: " + str(player.skill_points)
