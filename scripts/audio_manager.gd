extends Node

@onready var radio_player = $RadioPlayer
@onready var ambience_players = $AmbiencePlayers

var current_ambience: AudioStreamPlayer

var time: float = 0.0

func _ready():
	time = 0.0
	
	radio_player.set_bus("Radio")
	radio_player.stream = radio_stations["news"]
	#radio_player.play()
	
	for i in ambience_players.get_children():
		if i is AudioStreamPlayer:
			i.set_bus("Ambience")
	
	current_ambience = ambience_players.get_child(0)
	current_ambience.play()
	
	await get_tree().create_timer(0.0).timeout
	crossfade(ambience_players.get_child(1))
	
	# connect radio interaction to sync_radio radio via event bus

var radio_stations = {
	"music": preload("res://assets/audio/Nature Boy.ogg"),
	"news": preload("res://assets/audio/SpongeBob SquarePants Production Music - South Pacific Island II.mp3")
}

func sync_radio(station: String):
	var pos = radio_player.get_playback_position()
	var new_pos = time + radio_player.get_playback_position()
	
	### Test radio_player.seek(new_pos) if there are problems
	### .seek() moves the cursor w/out resuming/playing
	
	radio_player.stream.stop()
	radio_player.stream = radio_stations[station]
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
