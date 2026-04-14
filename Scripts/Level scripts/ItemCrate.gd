extends Node3D

@onready var item: Node3D = $"../Item"

func spawn_item():
	item.show()
