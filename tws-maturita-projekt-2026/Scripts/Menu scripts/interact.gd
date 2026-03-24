extends Label

func show_with(about : String, object : String):
	match about:
		"OpenDoor":
			text = "Zmačkní ( E ) pro otevření dveří"
	
	show()
