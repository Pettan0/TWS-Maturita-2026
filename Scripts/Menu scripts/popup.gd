extends Label
var weapon : String

func show_with(msg: String):
	match msg:
		"lockedWeapon":
			text = "Nevlastníš tuto zbraň."
		"cantEnter":
			text = "Nezabil jsi všechny nepřátelé."
		"blockedDoor":
			match randi_range(1,3):
				1:
					text = "Dveře jsou zablokované."
				2:
					text = "Dveře nejdou otevřít."
				3:
					text = "Namáš dost síly na otevření dveří."
	show()
	await get_tree().create_timer(2.0).timeout
	hide()
