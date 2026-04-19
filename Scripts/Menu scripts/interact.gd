extends Label

func show_with(about : String, type : String):

	match about:
		"OpenDoor":
			text = "Otevřít dveře "
		"UnlockDoor":
			text = "Odemknout dveře "
		"PickUpItem":
			text = "Sebrat "
			match type:
				"dagger":
					text += "dýku "
				"shortSword":
					text += "meč "
				"mace":
					text += "palcát "
				"longSword":
					text += "dlouhý meč "
				"poleHammer":
					text += "kladivo "
				"key":
					text += "klíč "
		"PullSword":
			text = "Pokusit se vytáhnout meč "
		"TalkToNpc":
			text = "Promluvit si "
		
	text += "( E )"
	show()
