extends Button

@export var skill_name := ""
@export var skill_desc := ""
@export var skill_id := ""

var skill_lvl = 0
var skill_max_lvl = 0

@onready var desc_name: Label = $"../../Description/Name"
@onready var desc_about: Label = $"../../Description/About"
@onready var desc_stats: Label = $"../../Description/Stats"
@onready var upgrade_btn: Button = $"../../Description/UpgradeBtn"


func _ready() -> void:
	pressed.connect(_button_pressed)

func _button_pressed():
	desc_name.text = skill_name
	desc_about.text = skill_desc
	desc_stats.text = "Vylepšeno "+str(skill_lvl)+"/"+str(skill_max_lvl)
	upgrade_btn.set_selected_skill_stats(skill_id,skill_lvl,skill_max_lvl)
