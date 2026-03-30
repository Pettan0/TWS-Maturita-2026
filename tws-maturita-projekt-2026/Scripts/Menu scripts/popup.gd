extends Label
var weapon : String

func show_with(msg: String):
	match msg:
		"lockedWeapon":
			text = "Nevlastníš tuto zbraň."
		"cantEnter":
			text = "Nezabil jsi všechny nepřátelé."
	show()
	await get_tree().create_timer(2.0).timeout
	hide()
