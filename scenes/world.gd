extends Node3D

@export var countdown_label_growth_interval: float = 5.0 # in seconds
@export var countdown_label_growth_scale: float = 1.2 # times the original scale

@onready var big_rock: Node3D = $BigRock
@onready var final_countdown_label: Label = $Control/FinalCountdownLabel

var big_rock_progress: float = 0.0

var final_countdown_timer: float = 0.0
var final_countdown_timer_text: String = ""

var countdown_tween: Tween
var final_countdown_time_elapsed: float = 0.0
var final_countdown_step: int = 0

func _ready() -> void:
	big_rock.progress_to_target.connect(func(percentage: float): big_rock_progress = percentage)
	big_rock.to_final_countdown_timer.connect(func(time: float): final_countdown_timer = time)
	big_rock.to_final_countdown_timer_text.connect(func(text: String): final_countdown_timer_text = text)

func _process(delta: float) -> void:
	if final_countdown_timer != 0.0:
		if not final_countdown_label.visible:
			final_countdown_label.visible = true
			# Grow from the label's center rather than its top-left corner.
			final_countdown_label.pivot_offset = final_countdown_label.size / 2.0
		final_countdown_label.text = final_countdown_timer_text

		final_countdown_time_elapsed += delta
		if final_countdown_time_elapsed >= 60.0:
			final_countdown_label.visible = false
			final_countdown_timer = 0.0
			return
		var target_step := int(final_countdown_time_elapsed / countdown_label_growth_interval)
		if target_step > final_countdown_step:
			final_countdown_step = target_step
			tween_grow_countdown_label()

func tween_grow_countdown_label() -> void:
	if countdown_tween and countdown_tween.is_valid():
		countdown_tween.kill()

	countdown_tween = get_tree().create_tween()
	countdown_tween.tween_property(final_countdown_label, "scale", Vector2.ONE * final_countdown_step * countdown_label_growth_scale, 0.01)
