extends Node3D

@export var target: Node3D
@export var minutes_to_reach_position: float = 15.0 # in minutes

var target_position: Vector3 = Vector3.ZERO
var start_position: Vector3 = Vector3.ZERO
var distance_to_target: float = 0.0
var time_until_target_position: float = 0.0

func _ready() -> void:
    target_position = target.global_position
    start_position = transform.origin
    minutes_to_reach_position *= 60.0
    distance_to_target = (target_position - start_position).length()
    time_until_target_position = minutes_to_reach_position;
    look_at(target_position)

func _physics_process(delta: float) -> void:
    move_towards_target(delta)

func move_towards_target(delta: float) -> void:
    time_until_target_position -= delta
    if time_until_target_position <= 0.0:
        transform.origin = target_position
    else:
        var direction = (target_position - transform.origin).normalized()
        var percentage_of_time_elapsed = 1.0 - (time_until_target_position / minutes_to_reach_position)
        transform.origin = start_position + direction * distance_to_target * percentage_of_time_elapsed
        print(percentage_of_time_elapsed)

        