extends Panel

@onready var player:= $"../../.."
@onready var skill_points: Label = $SkillPoints
@onready var stats: Label = $Stats

var player_data : PlayerData

func _ready() -> void:
	skill_points.text = "sp: " + str(player.skill_points)

func _on_button_back_pressed() -> void:
	player._skill_tree()

func _process(_delta: float) -> void:
	
	skill_points.text = "sp: " + str(player.skill_points)
	if player.player_data.skill_tree_changed:
		stats.text = ""
		if player.player_data.base_dmg != 0.0:
			stats.text = "Bonusové poškození: "+str(player.player_data.base_dmg)
		player.player_data.skill_tree_changed = false
	
