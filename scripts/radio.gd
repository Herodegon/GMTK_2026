extends Node3D

var freq: int = 0
var num_frequencies: int = 3

var target_rotation: float = 0.0
var target_position: float = -0.6

var time: float = 0.0

var radio_stations = [
	preload("res://assets/audio/news.mp3"),
	preload("res://assets/audio/Music.mp3"),
	preload("res://assets/audio/Mlatw radio.mp3"),
]

func _ready() -> void:
	#EventBus.radio_prompt.connect(prompt)
	EventBus.radio_interact.connect(change_freq)
	
	time = 0.0
	
	$Audio.set_bus("Radio")
	$Audio.stream = radio_stations[0]
	$Audio.play()

func prompt():
	# outline, visual button prompt
	pass

func _physics_process(delta: float) -> void:
	
	var minutes: int = floori($Timer.time_left / 60.0)
	$MeshInstance3D/Time.text = "06:%02d" % [43-minutes]
	
	$knob.rotation.z = lerp_angle($knob.rotation.z, deg_to_rad(target_rotation), 10.0 * delta)
	$needle.position.x = lerp($needle.position.x, target_position, 10.0 * delta)

func change_freq():
	freq += 1
	
	sync_radio()
	
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

func sync_radio():
	var pos = $Audio.get_playback_position()
	var new_pos = time + $Audio.get_playback_position()
	
	### Test radio_player.seek(new_pos) if there are problems
	### .seek() moves the cursor w/out resuming/playing
	
	$Audio.stop()
	$Audio.stream = radio_stations[freq % num_frequencies]
	$Audio.play(new_pos)
