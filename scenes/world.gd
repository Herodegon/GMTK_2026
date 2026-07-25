extends Node3D

@onready var big_rock: Node3D = $BigRock

var big_rock_progress: float = 0.0

func _ready() -> void:
	big_rock.progress_to_target.connect(func(percentage: float): big_rock_progress = percentage)

func _process(delta: float) -> void:
	print("Big rock progress: ", big_rock_progress)
