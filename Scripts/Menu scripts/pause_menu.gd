extends Control

@onready var player: CharacterBody3D = $"../../.."
@onready var settings: Control = $Settings


var pause = false

func _ready() -> void:
	settings.hide()
	
func _on_unpuase_pressed() -> void:
	settings.save_data()
	player._pauseMenu()
	
	
func _settings_show() -> void:
	settings.show()



func _on_menu_pressed() -> void:
	$"../../../Transition".visible = true
	$"../../../Transition/AnimationPlayer".play("Fade_in")
	await  get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Menu/Main menu.tscn")
