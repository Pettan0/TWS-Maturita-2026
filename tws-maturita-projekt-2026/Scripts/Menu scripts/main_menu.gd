extends Control

@onready var settings:= $Settings
@onready var credits: Panel = $Credits
@onready var debug_menu: Panel = $DebugMenu

var menu_show = false

func _ready() -> void:
	$Transition.visible = true
	$Transition/AnimationPlayer.play("Fade_out")
	await  get_tree().create_timer(1.0).timeout
	$Transition.visible = false

func _on_start_pressed() -> void:
	$Transition.visible = true
	$Transition/AnimationPlayer.play("Fade_in")
	await  get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Levels/Level01.scn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _settings_show() -> void:
	if !settings.visible and !credits.visible and !debug_menu.visible:
		settings.show()
	else:
		settings.hide()

func _on_credits_pressed() -> void:
	if !settings.visible and !credits.visible and !debug_menu.visible:
		credits.show()
	else:
		credits.hide()

func _on_button_debug_pressed() -> void:
	if !settings.visible and !credits.visible and !debug_menu.visible:
		debug_menu.show()
	else:
		debug_menu.hide()

func _on_credits_button_pressed() -> void:
	credits.hide()
