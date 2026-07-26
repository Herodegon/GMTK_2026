extends DirectionalLight3D

var target_rot_x : float
var target_rot_y : float

func _ready():
	target_rot_x = global_rotation_degrees.x
	target_rot_y = global_rotation_degrees.y
	EventBus.start_ending.connect(ending)

func ending():
	target_rot_x = 16.2
	target_rot_y = 175.2

func _physics_process(delta):
	global_rotation_degrees.x = lerpf(global_rotation_degrees.x, target_rot_x, 0.01 * delta)
	global_rotation_degrees.y = lerpf(global_rotation_degrees.y, target_rot_y, 0.01 * delta)
