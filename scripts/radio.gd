extends Node3D

var freq: int = 0
var num_frequencies: int = 3
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.radio_prompt.connect(prompt)
	EventBus.radio_interact.connect(change_freq)

func prompt():
	# outline, visual button prompt
	pass

func change_freq():
	freq += 1
	
	match freq % num_frequencies:
		0:
			print("radio: news")
		1:
			print("radio: music")
		2:
			print("radio: talkshow")

	knob_lerp(30.0)
func knob_lerp(degrees_rotating: float) -> void:
	if tween and tween.is_running():
		tween.kill()

	var local_axis: Vector3 = Vector3.FORWARD
	var target_basis: Basis = $knob.transform.basis.rotated(local_axis, deg_to_rad(degrees_rotating))
	
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($knob, "transform:basis", target_basis, 0.25)
