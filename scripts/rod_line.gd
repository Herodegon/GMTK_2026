extends Node3D

@export_group("Start and End Points")
@export var start_node: Node3D = null
@export var target_node: Node3D = null

@export_group("Rope Settings")
@export var rope_length: float = 32.0
@export var constraint: float = 1.0
@export var constraint_iterations: int = 4
@export var dampening: float = 0.9
@export var gravity: Vector3 = Vector3.DOWN * 9.81
@export var segment_radius: float = 0.1
@export var segment_color: Color = Color.WHITE

@onready var line = $Path3D

var position_list: PackedVector3Array = PackedVector3Array()
var prev_position_list: PackedVector3Array = PackedVector3Array()

var render_line: bool = false

func _ready() -> void:
    position_list.resize(int(rope_length / constraint))
    prev_position_list.resize(int(rope_length / constraint))

    for i in range(position_list.size()):
        position_list[i] = start_node.global_position
        prev_position_list[i] = start_node.global_position

func _physics_process(delta: float) -> void:
    if render_line:
        _update_points(delta)
        for i in range(constraint_iterations):
            _update_constraints()
        _update_curve()

func _update_points(delta: float) -> void:
    for i in range(position_list.size()):
        var current := position_list[i]
        var previous := prev_position_list[i]
        var velocity := (current - previous) * dampening
        prev_position_list[i] = current
        position_list[i] = current + velocity + gravity * delta * delta

func _update_constraints() -> void:
    position_list[0] = start_node.global_position
    position_list[position_list.size() - 1] = target_node.global_position

    for i in range(1, position_list.size() - 1):
        var a := position_list[i]
        var b := position_list[i + 1]
        var dist := (b - a).length()
        if dist == 0.0:
            continue
        var diff := (dist - constraint) / dist
        var offset := (b - a) * diff * 0.5

        if i != 0:
            position_list[i] += offset
        if i != position_list.size() - 1:
            position_list[i + 1] -= offset

func _update_curve() -> void:
    line.curve.clear_points()
    for p in position_list:
        line.curve.add_point(line.to_local(p))



