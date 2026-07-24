extends RigidBody3D

enum SwimState {
	IDLE,
	SEARCHING,
	FIGHTING
}

@export var tether_point: Node3D = null
@export var tether_radius: float = 4.0

@export_group("Swim Settings")
@export var impulse_strength: float = 1.0
@export var turn_speed: float = 0.3
@export var max_swim_cooldown: float = 3.0

var target_point: Vector3 = Vector3.ZERO
var swim_state: SwimState = SwimState.IDLE
var velocity: float = 0.0
var swim_cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	match swim_state:
		SwimState.IDLE:
			swim_cooldown -= delta
			if target_point == Vector3.ZERO or global_position.distance_to(target_point) < 0.1 or swim_cooldown <= 0.0:
				target_point = _get_point_near_tether()
				velocity = impulse_strength * randf_range(0.25, 1.0)
				swim_cooldown = randf_range(1.0, max_swim_cooldown)
			_look_at_target(target_point, delta)
			var to_target := target_point - global_position
			to_target.y = 0.0
			move_and_collide(to_target.normalized() * velocity * delta)
	print(global_position)

func _get_point_near_tether() -> Vector3:
	var random_angle = randf_range(0.0, TAU)
	var random_radius = randf_range(0.0, tether_radius)
	return tether_point.global_position + Vector3(cos(random_angle), 0.0, sin(random_angle)) * random_radius

func _look_at_target(target: Vector3, delta: float) -> void:
	var target_direction = (target - global_position).normalized()
	var target_angle = atan2(target_direction.x, target_direction.z)
	var new_angle = lerp_angle(rotation.y, target_angle, delta * turn_speed * TAU)
	rotation.y = new_angle