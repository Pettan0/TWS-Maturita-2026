extends Control

@onready var label: Label = $Panel/Label
@onready var tip: Label = $Panel/Tip

var timer = 0
var loading_progress = 0
var tip_timer = 0

func fade_out():
	create_tween().tween_property(self, "modulate:a", 1.0, 0.0).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(1.5).timeout
	create_tween().tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)

func fade_in():
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(1.5).timeout
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer > 0: 
		timer -= delta
	else:
		match loading_progress:
			0:
				label.text = "Načítání"
				loading_progress += 1
			1:
				label.text = "Načítání."
				loading_progress += 1
			2:
				label.text = "Načítání.."
				loading_progress += 1
			3:
				label.text = "Načítání..."
				loading_progress = 0
				
		timer = 1.0
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
