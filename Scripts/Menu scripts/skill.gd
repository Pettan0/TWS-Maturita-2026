extends Button
class_name SkillNode

@export var desc : String = ""
var unlocked = false
var node_id : String
@export var skill_id : String = ""

@onready var desc_label: Label = $Label


var player_data : PlayerData


var save_file_path = "user://save/"
var save_file_name = "PlayerData.tres"

func _ready() -> void:
	node_id = str(get_path())
	desc_label.text = desc
	player_data = load_data()
	for entry in player_data.unlocked_nodes:
		if entry["node_id"] == node_id:
			unlocked = true
			disabled = true
	
	if !unlocked:
		var skills = get_children()
		for skill in skills:
			skill.hide()

func save_data():
	ResourceSaver.save(player_data, save_file_path + save_file_name)

func load_data():
	if not DirAccess.dir_exists_absolute(save_file_path):
		DirAccess.make_dir_recursive_absolute(save_file_path)

	if FileAccess.file_exists(save_file_path + save_file_name):
		player_data = ResourceLoader.load(save_file_path + save_file_name)

	if player_data == null:
		player_data = PlayerData.new()
		save_data()

	return player_data

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

	unlocked = true
	save_data()
	disabled = true


func _on_mouse_entered() -> void:
	desc_label.visible = true

func _on_mouse_exited() -> void:
	desc_label.visible = false
