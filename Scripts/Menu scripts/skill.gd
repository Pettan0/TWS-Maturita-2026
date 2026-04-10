extends Button
class_name SkillNode

@export var desc : String = ""
var unlocked = false
@export var skill_id : String = ""
@export var node_id = get_path()
@onready var desc_box: Panel = $Panel
@onready var desc_label: Label = $Panel/Label

var player_data : PlayerData


var save_file_path = "user://save/"
var save_file_name = "PlayerData.tres"

func _ready() -> void:
	desc_label.text = desc
	player_data = load_data()
	
	if node_id in player_data.unlocked_nodes:
		unlocked = true
	
	if !unlocked:
		var skills = get_children()
		for skill in skills:
			skill.hide()

func save_data():
	ResourceSaver.save(player_data, save_file_path + save_file_name)

func load_data():
	if ResourceLoader.exists(save_file_path + save_file_name):
		return ResourceLoader.load(save_file_path + save_file_name)
		
	return PlayerData.new()

func _on_pressed():
	if unlocked:
		return

	if player_data.skill_points <= 0:
		print("Not enough skill points")
		return

	player_data.upgrade_skill(skill_id)
	player_data.skill_points -= 1
	
	player_data.unlocked_nodes.append(node_id)

	var skills = get_children()
	for skill in skills:
		skill.show()

	unlocked = true
	save_data()


func _on_mouse_entered() -> void:
	desc_box.visible = true

func _on_mouse_exited() -> void:
	desc_box.visible = false
