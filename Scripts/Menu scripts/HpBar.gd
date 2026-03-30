extends ProgressBar
@onready var label: Label = $Label

func update_hp(max_hp, hp):
	max_value = max_hp
	value = hp
	label.text = str(value) + " / " + str(max_value) 
