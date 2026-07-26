extends RigidBody3D

signal is_reel_spinning_changed(is_reel_spinning: bool)

var is_cast: bool = false
var occupied: bool = false

var starting_pos: Transform3D

func _ready() -> void:
	starting_pos = transform

#func _physics_process(delta: float) -> void:
	#pass

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_collision_layer_value(4): # is water?
		print("water")
		freeze = true
		$Plunk.play()
		print(global_position)
		is_reel_spinning_changed.emit(false)

## Attempts to claim this bob for a single fish. Returns true only for the first
## caller; subsequent callers in the same frame get false, so only one fish is caught.
func try_claim(fish: Node3D) -> bool:
	if occupied:
		return false
	print("hookline and sinker!")
	occupied = true
	freeze = false
	call_deferred("reparent", fish)
	$BobArea.call_deferred("set_collision_mask_value", 3, false)
	return true
