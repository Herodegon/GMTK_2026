extends Node3D

func _physics_process(delta):
	global_position = lerp(global_position, Vector3(0.5, .7, 0.0), 1.0 * delta)
	
	if global_position.distance_to(Vector3(0.5, 0.7, 0.0)) < 1.0:
		call_deferred("free")
