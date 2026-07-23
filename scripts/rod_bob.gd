extends RigidBody3D

var is_cast: bool = false

func _physics_process(delta: float) -> void:
	if is_cast:
		if $ShapeCast3D.is_colliding():
			is_cast = false
			freeze = true
			print("hit")
