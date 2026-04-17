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
					text += "dlouhéhý meče "
				"poleHammer":
					text += "kladivo "
		"PullSword":
			text = "Pokusit se vytáhnout meč "
	text += "( E )"
	show()
