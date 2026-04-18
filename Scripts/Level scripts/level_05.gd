extends Node3D

@onready var lol: Label = $SubViewport/lol

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lol.text = "192.168."+str(randi_range(1,255))+"."+str(randi_range(1,255))
