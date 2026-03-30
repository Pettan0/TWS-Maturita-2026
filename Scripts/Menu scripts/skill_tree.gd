extends Panel

@onready var basic:= $Basic
@onready var advanced:= $Advanced
@onready var ultimate:= $Ultimate

@onready var player:= $"../../.."

func _ready() -> void:
	basic.visible = true
	advanced.visible = false
	ultimate.visible = false

func _on_button_back_pressed() -> void:
	player._skill_tree()


func _on_button_basic_pressed() -> void:
	basic.visible = true
	advanced.visible = false
	ultimate.visible = false


func _on_button_anvanced_pressed() -> void:
	basic.visible = false
	advanced.visible = true
	ultimate.visible = false


func _on_button_ultimate_pressed() -> void:
	basic.visible = false
	advanced.visible = false
	ultimate.visible = true
