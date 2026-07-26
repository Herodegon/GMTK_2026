extends Node3D

func _ready():
	EventBus.start_ending.connect(ending)
	EventBus.fade_out.connect(fading)

func fading():
	var tween = get_tree().create_tween()
	tween.tween_property($Control2/ColorRect, "color", Color("190102ff"), 10.0)
	
	await tween.finished
	
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func ending():
	$Rumbling.play()
