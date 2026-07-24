extends Node

@onready var radio_player = $RadioPlayer

var time: float = 0.0

func _ready():
	time = 0.0
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
	
func _physics_process(delta):
	time += delta
