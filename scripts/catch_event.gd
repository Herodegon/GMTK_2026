extends Node

@export var catch_event_duration: float = 10.0
@export var pull_distance_per_press: float = 0.5 # meters the fish is reeled per press

@onready var player: Node3D = get_node_or_null("../../Player")
var current_fish: Node3D = null

var catch_event_timer: float = 0.0

var is_catch_event_active: bool = false

func _ready() -> void:
	EventBus.start_catch_event.connect(_on_start_catch_event)
	EventBus.send_fish.connect(_on_send_fish)

func _input(event: InputEvent) -> void:
	if not is_catch_event_active: return
	if event.is_pressed() and event.is_action_pressed("interact"):
		print("button pressed")
		if current_fish:
			current_fish.reel_in(player, pull_distance_per_press)

func _process(delta: float) -> void:
	if not is_catch_event_active: return
	print("catch event timer: ", catch_event_timer)
	catch_event_timer -= delta
	if catch_event_timer <= 0.0:
		is_catch_event_active = false
		EventBus.end_catch_event.emit()
		current_fish = null

func _on_start_catch_event() -> void:
	is_catch_event_active = true
	catch_event_timer = randf_range(catch_event_duration * 0.5, catch_event_duration)

func _on_send_fish(fish: Node3D) -> void:
	current_fish = fish

func _on_catch_area_area_entered(area: Area3D) -> void:
	print("catch area entered: ", area)
	if area.get_collision_layer_value(3): # is fish?
		print("fish entered catch area")
		var fish := area.get_parent()
		if fish == current_fish:
			print("fish is current fish")
			is_catch_event_active = false
			EventBus.win_catch_event.emit(current_fish)
			EventBus.end_catch_event.emit()
			current_fish = null
