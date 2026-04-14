extends Area3D

var player_in_area = false
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	body_entered.connect(_entered)
	body_exited.connect(_exited)

func _entered(body:Node3D):
	if (body.name == "Player"):
		player_in_area = true
		collision_shape.scale = Vector3(10.0, 10.0, 10.0)

func _exited(body:Node3D):
	if (body.name == "Player"):
		player_in_area = false

func _is_player_in_area() -> bool:
	return player_in_area
