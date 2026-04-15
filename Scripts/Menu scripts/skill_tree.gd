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
		#defence
		if player.player_data.can_block:
			stats.text += "Blokované poškození: "+str(player.player_data.block_dmg*100)+"%\n"
		if player.player_data.max_hp > 100.0:
			stats.text += "Maximální životy: "+str(player.player_data.max_hp)+"\n"
		if player.player_data.can_kick:
			stats.text += "Poškození kopnutí: "+str(player.player_data.kick_dmg)+"\n"
			stats.text += "Cooldown kopnutí: "+str(player.player_data.kick_cooldown)+"\n"
			
		#offence skills
		if player.player_data.base_dmg > 0.0:
			stats.text += "Bonusové poškození: "+str(player.player_data.base_dmg)+"\n"
		if player.player_data.attack_speed > 1.0:
			stats.text += "Rychlost útoku: "+str(player.player_data.attack_speed)+"\n"
		if player.player_data.attack_stamina < 15:
			stats.text += "Stamina na útok: "+str(player.player_data.attack_stamina)+"\n"
		player.player_data.skill_tree_changed = false
		
		#defence
		if player.player_data.max_stamina > 100:
			stats.text += "Maximální stamina: "+str(player.player_data.max_stamina)+"\n"
		if player.player_data.sregen > 0.3:
			stats.text += "Regenerace staminy: "+str(player.player_data.sregen)+"\n"
		if player.player_data.u_hp_regen:
			stats.text += "Čas mezi regenerací: "+str(player.player_data.rtimer_to_wait)+"\n"
			stats.text += "Hodnoda regenerace: "+str(player.player_data.r_per_time)+"\n"
			
