extends Node

@export_group("Pool Settings")
@export var spawn_fish: bool = true
@export var fish_scene: PackedScene = null
@export var fish_count: int = 10
@export var fish_parent: Node3D = null

var tether_radius: float = 0.0
var fish_pool: Array[Node3D] = []

func _ready() -> void:
	if !spawn_fish: return
	spawn_fish_batch(fish_count)
	EventBus.remove_fish.connect(remove_fish)

func _process(delta: float) -> void:
	if fish_pool.size() < fish_count - 5:
		spawn_fish_batch(5)

func spawn_fish_batch(number_of_fish: int = 5) -> void:
	for i in range(number_of_fish):
		var fish = fish_scene.instantiate()
		if fish_pool.size() == 0:
			tether_radius = fish.tether_radius
		fish.tether_point = fish_parent
		fish_pool.append(fish)
		add_child(fish)
		fish.global_position = _get_random_position()
		fish.global_rotation = fish_parent.global_rotation

func remove_fish(fish: Node3D) -> void:
	fish_pool.erase(fish)
	fish.queue_free()

func _get_random_position() -> Vector3:
	var random_angle = randf_range(0.0, TAU)
	var random_radius = randf_range(0.0, tether_radius)
	return fish_parent.global_position + Vector3(cos(random_angle), 0.0, sin(random_angle)) * random_radius
