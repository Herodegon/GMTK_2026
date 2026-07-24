extends Node

@onready var radio_player = $RadioPlayer
@onready var ambience_players = $AmbiencePlayers

var current_station: int = 0
var current_ambience: AudioStreamPlayer

var time: float = 0.0

func _ready():
	time = 0.0
	
	radio_player.set_bus("Radio")
	radio_player.stream = radio_stations[0]
	radio_player.play()
	
	EventBus.radio_interact.connect(sync_radio)
	
	for i in ambience_players.get_children():
		if i is AudioStreamPlayer:
			i.set_bus("Ambience")
	
	# connect radio interaction to sync_radio radio via event bus

var radio_stations = [
	preload("res://assets/audio/Nature Boy.ogg"),
	preload("res://assets/audio/sponge.mp3"),
	preload("res://assets/audio/mario.mp3"),
]

func sync_radio():
	current_station += 1
	
	var pos = radio_player.get_playback_position()
	var new_pos = time + radio_player.get_playback_position()
	
	### Test radio_player.seek(new_pos) if there are problems
	### .seek() moves the cursor w/out resuming/playing
	
	radio_player.stop()
	radio_player.stream = radio_stations[current_station % len(radio_stations)]
	radio_player.play(new_pos)

func crossfade(next_ambience: AudioStreamPlayer):
	
	var tween = get_tree().create_tween()
	tween.tween_property(current_ambience, "volume_linear", 0.0, 10.0)
	
	next_ambience.volume_linear = 0.0
	next_ambience.play(time)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(next_ambience, "volume_linear", 1.0, 10.0)
	
	tween.tween_callback(current_ambience.stop)
	current_ambience = next_ambience
	next_ambience = null
	

func _physics_process(delta):
	time += delta
