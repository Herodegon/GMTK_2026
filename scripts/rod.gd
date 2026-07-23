extends Node3D

enum RotationDirection {
    CLOCKWISE = 1,
    COUNTER_CLOCKWISE = -1
}

@onready var bob_start_position: Vector3 = $BobRestNode.global_position

@onready var rod_mesh := $Mesh/RodMesh
@onready var wheel_mesh := $Mesh/RodMesh/WheelMesh
@onready var rod_line := $RodLine
@onready var bob = rod_line.target_node as RigidBody3D

@export var spin_speed: float = 8.0
@export var cast_direction: Vector3 = Vector3(0.0, 1.0, -2.0)
@export var cast_force: float = 100.0
var is_cast: bool = false
var reel_direction: RotationDirection = RotationDirection.CLOCKWISE

func _ready() -> void:
    _bob_set_rest()

func _process(delta: float) -> void:
    if is_cast:
        _spin_wheel(delta, reel_direction)

func _bob_set_rest() -> void:
    bob.global_position = bob_start_position
    bob.gravity_scale = 0.0

func _spin_wheel(delta: float, direction: RotationDirection) -> void:
    var delta_q = Quaternion(Vector3.UP, spin_speed * delta * float(direction))
    wheel_mesh.quaternion = wheel_mesh.quaternion * delta_q

func _animation_cast_rod() -> void:
    is_cast = true

    bob.apply_central_force(cast_direction.normalized() * cast_force)
    bob.gravity_scale = 1.0
    reel_direction = RotationDirection.CLOCKWISE
