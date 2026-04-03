extends Button
class_name SkillNode

@export var skill_desc : String
@export var skill_id : String

var skill_tree_data : SkillTreeData



func _on_pressed():
	var skills = get_children()
	for skill in skills:
		skill.show()
