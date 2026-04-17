extends Button
class_name SkillNode

@export var desc : String = ""
var unlocked = false
@export var skill_id : String = ""
@export var type : String = "B"
@export var node_id : String

@onready var desc_label: Label = $Label

var player_data : PlayerData


var save_file_path = "user://save/"
var save_file_name = "PlayerData.tres"

func save_data():
	ResourceSaver.save(player_data, save_file_path + save_file_name)

func load_data():
	if FileAccess.file_exists(save_file_path + save_file_name):
		var data = ResourceLoader.load(save_file_path + save_file_name)

		if data:
			player_data = data
	else:
		player_data = PlayerData.new()

func sync_from_data():
	for node in player_data.unlocked_nodes:
		if node["node_id"] == node_id:
			unlocked = true
			disabled = true

			for child in get_children():
				child.show()

func _ready() -> void:
	
	load_data()
	desc_label.text = desc
	desc_label.hide()
	for child in get_children():
		child.hide()
	sync_from_data()

func _on_pressed():
	if player_data.skill_points <= 0:
		return

	player_data.upgrade_skill(skill_id)
	player_data.skill_points -= 1
	
	player_data.unlocked_nodes.append({
		"node_id": node_id,
		"skill_id": skill_id
	})
	var skills = get_children()
	for skill in skills:
		skill.show()
	
	SoundManager.upgrade_sfx(type)
	unlocked = true
	disabled = true
	player_data.skill_tree_changed = true
	

func _on_mouse_entered() -> void:
	desc_label.visible = true

func _on_mouse_exited() -> void:
	desc_label.visible = false
