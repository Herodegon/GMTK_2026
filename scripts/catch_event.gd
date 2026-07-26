extends Node

@export var catch_event_duration: float = 10.0
@export var button_press_required_percentage: float = 0.75

var catch_event_timer: float = 0.0
var button_press_required: int = 0
var button_press_total: int = 0

var is_catch_event_active: bool = false

func _ready() -> void:
	EventBus.start_catch_event.connect(_on_start_catch_event)

func _input(event: InputEvent) -> void:
	if not is_catch_event_active: return
	if event.is_pressed() and event.is_action_pressed("interact"):
		print("button pressed")
		button_press_total += 1

func _process(delta: float) -> void:
	if not is_catch_event_active: return
	print("catch event timer: ", catch_event_timer)
	catch_event_timer -= delta
	if catch_event_timer <= 0.0:
		is_catch_event_active = false
		EventBus.end_catch_event.emit()
		if button_press_total >= button_press_required:
			EventBus.win_catch_event.emit()

func _on_start_catch_event() -> void:
	is_catch_event_active = true
	catch_event_timer = randf_range(catch_event_duration * 0.5, catch_event_duration)
	var min_button_press = int(catch_event_duration * button_press_required_percentage)
	button_press_required = randi_range(min_button_press, min_button_press * 2)
	button_press_total = 0
