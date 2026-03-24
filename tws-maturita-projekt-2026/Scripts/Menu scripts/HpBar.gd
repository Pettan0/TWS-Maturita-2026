extends ProgressBar
@onready var label: Label = $Label

func update_hp(max_hp, hp):
	max_value = max_hp
	if (value - hp) >= 0:
		value = hp
	else:
		value = 0
	label.text = str(value) + " / " + str(max_value) 
