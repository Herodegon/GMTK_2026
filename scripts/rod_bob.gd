extends RigidBody3D

var is_cast: bool = false
var occupied: bool = false

var starting_pos : Transform3D


func _ready() -> void:
	starting_pos = transform

func _physics_process(delta: float) -> void:
	pass#if is_cast:
		#if $ShapeCast3D.is_colliding():
			#is_cast = false
			#freeze = true
			#print("hit")


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_collision_layer_value(4): # is water?
		print("water")
		freeze = true
	elif area.get_collision_layer_value(3) and !occupied: #is fish?
		print("hookline and sinker!")
		occupied = true
		$BobArea.call_deferred("set_collision_mask_value", 3, false)
		EventBus.caught_fish.emit()
