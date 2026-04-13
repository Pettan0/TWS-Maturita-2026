extends Panel

@onready var player:= $"../../.."
@onready var skill_points: Label = $SkillPoints
@onready var stats: Label = $Stats


func _ready() -> void:
	skill_points.text = "sp: " + str(player.skill_points)

func _on_button_back_pressed() -> void:
	player._skill_tree()

func _process(_delta: float) -> void:
	skill_points.text = "sp: " + str(player.skill_points)
	stats.text = "Bonusové poškození: " + str(player.base_dmg)+"\nRychlost útoku: "+ str(player.player_data.attack_speed)+"\nStamina na útok: "+ str(player.player_data.attack_stamina)
