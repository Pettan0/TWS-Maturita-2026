extends Node3D

@export var speed := 12.0
@export var damage := 5.0
@export var lifetime := 4.0
@export var visual_y_rotation_offset := 0.0

var move_direction := Vector3.ZERO

@onready var hitbox: Area3D = get_node_or_null("Area3D")


func _ready() -> void:
	if move_direction == Vector3.ZERO:
		move_direction = -global_transform.basis.z

	move_direction = move_direction.normalized()
	_face_move_direction()

	if hitbox:
		if not hitbox.body_entered.is_connected(_on_body_entered):
			hitbox.body_entered.connect(_on_body_entered)

	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	global_position += move_direction * speed * delta
	_face_move_direction()


func set_direction(direction: Vector3) -> void:
	if direction.length() < 0.1:
		return

	move_direction = direction.normalized()
	_face_move_direction()


func _face_move_direction() -> void:
	var flat_direction = move_direction
	flat_direction.y = 0.0

	if flat_direction.length() < 0.1:
		return

	look_at(global_position + flat_direction.normalized(), Vector3.UP)
	rotate_y(deg_to_rad(visual_y_rotation_offset))


func _on_body_entered(body: Node) -> void:
	if body == null:
		return

	var target := body
	if not target.is_in_group("player") and target.get_parent() != null:
		target = target.get_parent()

	if target.is_in_group("player"):
		if target.has_method("_hit"):
			target._hit(damage)

		queue_free()
