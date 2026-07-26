extends Node

@export_group("Pool Settings")
@export var spawn_fish: bool = true
@export var fish_scene: PackedScene = null
@export var fish_count: int = 10
@export var fish_parent: Node3D = null

var fish_pool: Array[Node3D] = []

func _ready() -> void:
	if !spawn_fish: return
	
	for i in range(fish_count):
		var fish = fish_scene.instantiate()
		fish.tether_point = fish_parent
		fish_pool.append(fish)
		add_child(fish)
		var variance = Vector3(randf_range(-3.0, 3.0), 0.0, randf_range(-3.0, 3.0))
		fish.global_position = fish_parent.global_position + variance
		fish.global_rotation = fish_parent.global_rotation
