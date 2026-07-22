extends Node3D

var target_transform : Transform3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta):
	
	if Input.is_action_just_pressed("up"):
		target_transform = $Position1.transform
	
	if Input.is_action_just_pressed("down"):
		target_transform = $Position2.transform
	
	$Camera.transform = lerp($Camera.transform, target_transform, 3.0 * delta)
