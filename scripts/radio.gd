extends Node3D

var freq: int = 0
var num_frequencies: int = 3

var target_rotation: float = 0.0
var target_position: float = -0.6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.radio_prompt.connect(prompt)
	EventBus.radio_interact.connect(change_freq)

func prompt():
	# outline, visual button prompt
	pass

func _physics_process(delta: float) -> void:
	$knob.rotation.z = lerp_angle($knob.rotation.z, deg_to_rad(target_rotation), 10.0 * delta)
	$needle.position.x = lerp($needle.position.x, target_position, 10.0 * delta)

func change_freq():
	freq += 1
	
	match freq % num_frequencies:
		0:
			print("radio: news")
			target_rotation = 30.0
			target_position = -.60
		1:
			print("radio: music")
			target_rotation = 90.0
			target_position = -.10
		2:
			print("radio: talkshow")
			target_rotation = 130.0
			target_position = .38
