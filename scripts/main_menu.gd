extends Node2D


func _on_start_pressed() -> void:
	
	$AnimationPlayer.play("fade out")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
