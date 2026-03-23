extends ProgressBar

func update_hp(max_hp, hp):
	max_value = max_hp
	if (value - hp) >= 0:
		value = hp
	else:
		value = 0
