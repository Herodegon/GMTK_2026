extends Node3D

enum RotationDirection {
	CLOCKWISE = 1,
	COUNTER_CLOCKWISE = -1
}

@onready var bob_start_position := $BobRestNode

@onready var rod_mesh := $Mesh/RodMesh
@onready var wheel_mesh := $Mesh/RodMesh/WheelMesh
@onready var rod_line := $RodLine
@onready var bob = $BobRestNode/RodBob as RigidBody3D

@export var rest_rope_length: float = 1.0
@export var cast_rope_length: float = 16.0
@export var spin_speed: float = 8.0
@export var cast_direction: Vector3 = Vector3(0.0, 1.0, -2.0)
@export var cast_force: float = 100.0

var is_cast: bool = false
var reel_direction: RotationDirection = RotationDirection.CLOCKWISE

func _ready() -> void:
	rod_line.set_rope_length(rest_rope_length)
	_bob_set_rest()

func _bob_set_rest() -> void:
	bob.global_position = bob_start_position.global_position
	bob.freeze = true

func _spin_wheel(delta: float, direction: RotationDirection) -> void:
	var delta_q = Quaternion(Vector3.UP, spin_speed * delta * float(direction))
	wheel_mesh.quaternion = wheel_mesh.quaternion * delta_q

func cast_rod() -> void:
	if not bob.is_cast:
		$Animator.play("Cast")

func _animation_call_cast() -> void:
	bob.apply_central_force(cast_direction.normalized() * cast_force)
	bob.freeze = false
	bob.is_cast = true

	rod_line.set_rope_length(cast_rope_length)
	reel_direction = RotationDirection.CLOCKWISE
	_spin_wheel(spin_speed, reel_direction)
