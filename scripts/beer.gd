extends Node3D

var drinking: bool = false

func _ready() -> void:
	EventBus.beer_interact.connect(drink)

func drink():
	while !drinking:
		drinking = true
		$Animator.play("drink")

func _on_animator_animation_finished(anim_name):
	if anim_name == "drink":
		drinking = false
