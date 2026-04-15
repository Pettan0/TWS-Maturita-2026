extends Label
var weapon : String

func show_with(msg: String):
	match msg:
		"lockedWeapon":
			text = "Nevlastníš tuto zbraň."
		"lockedAbility":
			text = "Neodemkl jsi tuto schopnost."
		"abilityOnCooldown":
			text = "Jsi příliš unavený aby jsi použil tuto schopnost."
		"outOfStamina":
			text = "Jsi příliš unavený, odpočiň si."
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
func show_custom(msg: String):
	text = msg
	show()
	await get_tree().create_timer(2.0).timeout
	hide()
