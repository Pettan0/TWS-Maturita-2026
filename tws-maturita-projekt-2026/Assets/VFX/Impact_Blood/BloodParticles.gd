extends GPUParticles3D

@export var min_amount := 6
@export var max_amount := 18

@export var min_velocity := 5.0
@export var max_velocity := 12.0

func trigger(direction: Vector3):
	# Random amount per hit
	amount = randi_range(min_amount, max_amount)
	
	var mat := process_material as ParticleProcessMaterial
	
	# Random velocity per hit
	mat.initial_velocity_min = randf_range(min_velocity, max_velocity)
	mat.initial_velocity_max = mat.initial_velocity_min + 2.0
	
	# Direction of blood spray
	var local_dir = global_transform.basis.inverse() * direction
	mat.direction = local_dir.normalized()
	
	restart()
	emitting = true
	
