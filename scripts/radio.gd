extends Node3D

var freq: int = 0
var num_frequencies: int = 3

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
			print("readio: news")
		1:
			print("radio: music")
		2:
			print("radio: talkshow")
