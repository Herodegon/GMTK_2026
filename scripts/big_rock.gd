extends Node3D

signal progress_to_target(percentage: float)
signal to_final_countdown_timer(float: float)
signal to_final_countdown_timer_text(text: String)

@export var target: Node3D
@export var minutes_to_reach_position: float = 15.0 # in minutes

@onready var countdown_label: Label3D = $CountdownLabel

var target_position: Vector3 = Vector3.ZERO
var start_position: Vector3 = Vector3.ZERO
var distance_to_target: float = 0.0

var time_until_target_position: float = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_progress_time_5_percent"):
		time_until_target_position -= minutes_to_reach_position * 0.05

func _ready() -> void:
	target_position = target.global_position
	start_position = transform.origin
	minutes_to_reach_position *= 60.0
	distance_to_target = (target_position - start_position).length()
	time_until_target_position = minutes_to_reach_position;
	look_at(target_position)

func _physics_process(delta: float) -> void:
	move_towards_target(delta)
	update_timer_label()

func move_towards_target(delta: float) -> void:
	time_until_target_position -= delta
	if time_until_target_position <= 0.0:
		transform.origin = target_position
	else:
		var percentage_of_time_elapsed = 1.0 - (time_until_target_position / minutes_to_reach_position)
		transform.origin = start_position.lerp(target_position, percentage_of_time_elapsed)
		progress_to_target.emit(percentage_of_time_elapsed)

func update_timer_label() -> void:
	var countdown_text: String = "%02d:%02d:%02d" % [int(time_until_target_position)/60.0, int(time_until_target_position)%60, int(time_until_target_position*100)%100]
	if time_until_target_position <= 60.0:
		if countdown_label.visible:
			countdown_label.visible = false
		to_final_countdown_timer.emit(time_until_target_position)
		to_final_countdown_timer_text.emit(countdown_text)
		return
	countdown_label.text = countdown_text
