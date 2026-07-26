extends Control

@export var big_rock: Node3D = null
@export var countdown_label_growth_interval: float = 5.0 # in seconds
@export var countdown_label_growth_scale: float = 1.2 # times the original scale

@export var fish_count_label: Label = null

@export var tutorial_prompt: Control = null

@onready var final_countdown_label: Label = $FinalCountdownLabel

var big_rock_progress: float = 0.0
var tutorial_prompt_timer: float = 7.0
var can_show_tutorial_prompt: bool = true
var tutorial_tween: Tween

var final_countdown_timer: float = 0.0
var final_countdown_timer_text: String = ""

var countdown_tween: Tween
var final_countdown_time_elapsed: float = 0.0
var final_countdown_step: int = 0

func _ready() -> void:
	EventBus.progress_to_target.connect(func(percentage: float): big_rock_progress = percentage)
	EventBus.to_final_countdown_timer.connect(func(time: float): final_countdown_timer = time)
	EventBus.to_final_countdown_timer_text.connect(func(text: String): final_countdown_timer_text = text)
	EventBus.update_fish_count.connect(func(count: int): fish_count_label.text = "Fish Count: " + str(count))
	EventBus.hide_tutorial_prompt.connect(func() -> void:
		can_show_tutorial_prompt = false
		if tutorial_tween and tutorial_tween.is_valid():
			tutorial_tween.kill()
		tutorial_prompt.visible = false
	)

func _process(delta: float) -> void:
	if final_countdown_timer > 0.0:
		if not final_countdown_label.visible:
			#final_countdown_label.visible = true
			# Grow from the label's center rather than its top-left corner.
			final_countdown_label.pivot_offset = final_countdown_label.size / 2.0
		final_countdown_label.text = final_countdown_timer_text

		final_countdown_time_elapsed += delta
		var target_step := int(final_countdown_time_elapsed / countdown_label_growth_interval)
		if target_step > final_countdown_step:
			final_countdown_step = target_step
			tween_grow_countdown_label()
	elif final_countdown_label.visible:
		final_countdown_label.visible = false
	tutorial_prompt_timer -= delta
	if tutorial_prompt_timer <= 0.0 and can_show_tutorial_prompt:
		show_tutorial_prompt()

func tween_grow_countdown_label() -> void:
	if countdown_tween and countdown_tween.is_valid():
		countdown_tween.kill()

	# Cumulative: 1.0x, 1.2x, 1.4x, ... one step per interval.
	var target_scale := Vector2.ONE * (1.0 + (countdown_label_growth_scale - 1.0) * final_countdown_step)
	countdown_tween = get_tree().create_tween()
	countdown_tween.tween_property(final_countdown_label, "scale", target_scale, 0.01)

func show_tutorial_prompt() -> void:
	can_show_tutorial_prompt = false
	var alpha = tutorial_prompt.modulate.a
	tutorial_prompt.modulate.a = 0.0
	tutorial_prompt.visible = true
	tutorial_tween = get_tree().create_tween()
	tutorial_tween.tween_property(tutorial_prompt, "modulate:a", alpha, 1.0)
