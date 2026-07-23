extends Node3D

var target_transform: Transform3D
var camera_lock: bool = false

var interaction: int
enum interactions {FISH, RADIO, BEER, BAIT} 

func _physics_process(delta):
	if !camera_lock:
		handle_camera()
		$Camera.transform = lerp($Camera.transform, target_transform, 3.0 * delta)
	else:
		$Camera.transform = lerp($Camera.transform, $Up.transform, 3.0 * delta)
	

func _input(event):
	if event is InputEvent:
		if event.is_pressed() and event.is_action_pressed("interact"):
			interact()

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

func handle_camera():
	if Input.is_action_just_pressed("up"):
		target_transform = $Up.transform
		interaction = interactions.FISH
	
	if Input.is_action_just_pressed("down"):
		target_transform = $Down.transform
		interaction = interactions.BAIT
	
	if Input.is_action_just_pressed("left"):
		target_transform = $Left.transform
		interaction = interactions.RADIO
	
	if Input.is_action_just_pressed("right"):
		target_transform = $Right.transform
		interaction = interactions.BEER
