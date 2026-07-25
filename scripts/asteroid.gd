extends CSGMesh3D

@export var target: Node3D

func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target.global_position, 10.0 * 60.0)
