extends Control

@onready var tip: Label = $Panel/Tip
@onready var transition: Control = $Transition

var tip_timer = 0.0


func _process(delta: float) -> void:
	if tip_timer > 0:
		tip_timer -= delta
	else:
		tip_timer = 5.0
		tip.text = "TIP: "
		match randi_range(1,3):
			1:
				tip.text += "můžeš otevřít skill tree pro vylepšení ( K )"
			2:
				tip.text += "v krabicích se mohou nacházet zbraně"
			3:
				tip.text += "můžeš změnit zbrane ( 1-6 )"
				

func _on_button_continue_pressed() -> void:
	$Transition.visible = true
	$Transition/AnimationPlayer.play("Fade_in")
	await  get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Levels/Level01.scn")


func _on_button_menu_pressed() -> void:
	pass # Replace with function body.
