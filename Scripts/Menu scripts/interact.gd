extends Label

func show_with(about : String, type : String):
	text = "Zmačkní ( E ) pro "
	match about:
		"OpenDoor":
			text += "otevření dveří."
		"UnlockDoor":
			text += "udemknutí dveří."
		"PickUpItem":
			text += "sebrání "
			match type:
				"dagger":
					text += "dýky."
				"shortSword":
					text += "meče."
				"mace":
					text += "palcátu."
				"longSword":
					text += "dlouhého meče."
				"poleHammer":
					text += "kladiva."
	show()
