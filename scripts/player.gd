extends Node3D

@export var camera: Camera3D
@onready var rod = $Rod

@export var camera_speed: float = 3.0

var target_transform: Transform3D
var camera_lock: bool = false
var is_in_tutorial: bool = true

var total_caught_fish: int = 0

var interaction: int
enum interactions {FISH, RADIO, BEER, BAIT}

func _ready() -> void:
	EventBus.start_catch_event.connect(_on_start_catch_event)
	EventBus.end_catch_event.connect(_on_end_catch_event)
	EventBus.win_catch_event.connect(_on_win_catch_event)

func _physics_process(delta):
	if !camera_lock:
		camera.transform = lerp(camera.transform, target_transform, camera_speed * delta)
	else:
		camera.transform = lerp(camera.transform, $Up.transform, camera_speed * delta)

func _input(event):
	if event is InputEvent:
		if event.is_pressed() and event.is_action_pressed("interact"):
			interact()
		
		if !camera_lock:
			if event.is_pressed() and event.is_action_pressed("up"):
				target_transform = $Up.transform
				interaction = interactions.FISH
			
			if Input.is_action_just_pressed("left"):
				target_transform = $Left.transform
				interaction = interactions.RADIO
			
			if Input.is_action_just_pressed("right"):
				target_transform = $Right.transform
				interaction = interactions.BEER

func _on_start_catch_event() -> void:
	camera_lock = true

func _on_end_catch_event() -> void:
	camera_lock = false

func _on_win_catch_event(fish: Node3D) -> void:
	total_caught_fish += 1
	EventBus.update_fish_count.emit(total_caught_fish)
	rod.animation_reel_big_fish(fish)

func interact():
	# Node communication handled by EventBus.
	# Define interaction signal in EventBus (EventBus.signal_name.emit(args))
	# Connect interaction signal in interacted object (EventBus.signal_name.connect(method_name))
	
	if !camera_lock:
		match interaction:
			0:
				print("fish")
				if is_in_tutorial:
					EventBus.hide_tutorial_prompt.emit()
					is_in_tutorial = false
				rod.cast_rod()
			1:
				print("radio")
				EventBus.radio_interact.emit()
			2:
				print("beer")
				EventBus.beer_interact.emit()
