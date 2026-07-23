extends Node3D

@onready var camera = %Camera

@export var camera_speed: float = 3.0

var target_transform: Transform3D
var camera_lock: bool = false

var interaction: int
enum interactions {FISH, RADIO, BEER, BAIT}

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
			
			if event.is_pressed() and event.is_action_pressed("down"):
				target_transform = $Down.transform
				interaction = interactions.BAIT
			
			if Input.is_action_just_pressed("left"):
				target_transform = $Left.transform
				interaction = interactions.RADIO
			
			if Input.is_action_just_pressed("right"):
				target_transform = $Right.transform
				interaction = interactions.BEER

func interact():
	match interaction:
		0:
			print("fish")
			$Rod/Animator.play("Cast")
		1:
			print("radio")
		2:
			print("beer")
		3:
			print("bait")
