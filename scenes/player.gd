extends Node3D

@export var camera: Camera3D = null

@onready var rod := $Rod

var target_transform: Transform3D
var camera_lock: bool = false

func _physics_process(delta):
	
	if Input.is_action_just_pressed("interact"):
		rod.cast_rod()
	
	if !camera_lock:
		handle_camera()
		camera.transform = lerp(camera.transform, target_transform, 3.0 * delta)
	else:
		camera.transform = lerp(camera.transform, $Up.transform, 3.0 * delta)

func handle_camera():
	if Input.is_action_just_pressed("up"):
		target_transform = $Up.transform
	
	if Input.is_action_just_pressed("down"):
		target_transform = $Down.transform
	
	if Input.is_action_just_pressed("left"):
		target_transform = $Left.transform
	
	if Input.is_action_just_pressed("right"):
		target_transform = $Right.transform
