enum SkillID {
	TEST,
	DMG1,
	AGI1,
	URUN,
	GOLD1
}

@export var skills := {
	SkillID.TEST:  
		{"id": "test",
		"lvl": 0,
		"max_lvl": 0},
	SkillID.DMG1:
		{"id": "dmg1",
		"lvl": 0,
		"max_lvl": 5},
	SkillID.AGI1:
		{"id": "agi1",
		"lvl": 0,
		"max_lvl": 2},
	SkillID.URUN:
		{"id": "uRun",
		"lvl": 0,
		"max_lvl": 1},
	SkillID.GOLD1: 
		{"id": "gold1",
		"lvl": 0,
		"max_lvl": 4}
}
