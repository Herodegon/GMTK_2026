extends Node3D

enum RotationDirection {
	CLOCKWISE = 1,
	COUNTER_CLOCKWISE = -1
}

@onready var bob_start_position := $BobRestNode

@onready var rod_mesh := $Mesh/RodMesh
@onready var wheel_mesh := $Mesh/RodMesh/WheelMesh
@onready var rod_line := $RodLine
@onready var bob = $BobRestNode/RodBob as RigidBody3D

@export var rest_rope_length: float = 1.0
@export var reel_rope_length: float = 4.0
@export var cast_rope_length: float = 16.0
@export var spin_speed: float = 8.0
@export var cast_direction: Vector3 = Vector3(0.0, 1.0, -2.0)
@export var cast_force: float = 100.0

@export var input_buffer_time: float = 0.5

var is_reel_spinning: bool = false
var is_catching: bool = false
var reel_direction: RotationDirection = RotationDirection.CLOCKWISE
var input_buffer_timer: float = 0.0

var reel_tween: Tween = null

func _ready() -> void:
	rod_line.set_rope_length(rest_rope_length)
	_bob_set_rest()
	bob.is_reel_spinning_changed.connect(func(is_spinning: bool) -> void:
		is_reel_spinning = is_spinning
	)
	
	EventBus.start_catch_event.connect(_on_start_catch_event)
	EventBus.end_catch_event.connect(_on_end_catch_event)

func _process(delta: float) -> void:
	if is_reel_spinning:
		_spin_wheel(delta, reel_direction)

func _bob_set_rest() -> void:
	bob.global_position = bob_start_position.global_position
	bob.freeze = true
	bob.is_cast = false

func _spin_wheel(delta: float, direction: RotationDirection) -> void:
	var delta_q = Quaternion(Vector3.UP, spin_speed * delta * float(direction))
	wheel_mesh.quaternion = wheel_mesh.quaternion * delta_q

func cast_rod() -> void:
	if not bob.is_cast and input_buffer_timer <= 0.0:
		$Animator.play("Cast")

func _on_start_catch_event() -> void:
	reel_direction = RotationDirection.COUNTER_CLOCKWISE
	is_reel_spinning = true
	$Animator.play("Catch")

func _on_end_catch_event() -> void:
	_animation_reel_back()
	if reel_tween: return
	rod_line.set_rope_length(rest_rope_length)
	bob.reparent(bob_start_position)
	_bob_set_rest()
	input_buffer_timer = input_buffer_time
#
#func _physics_process(delta):
	#if input_buffer_timer >= 0.0:
		#input_buffer_timer -= delta

func _animation_reel_back() -> void:
	$Animator.play_backwards("Reel")

func _animation_call_cast() -> void:
	bob.apply_central_force(cast_direction.normalized() * cast_force)
	bob.freeze = false
	bob.is_cast = true
	bob.occupied = false

	rod_line.set_rope_length(cast_rope_length)
	reel_direction = RotationDirection.CLOCKWISE
	is_reel_spinning = true

func animation_reel_big_fish(fish: Node3D) -> void:
	rod_line.set_rope_length(reel_rope_length)
	reel_tween = create_tween()
	reel_tween.tween_property(fish, "global_position", bob_start_position.global_position, 1.5)
	# Detach the bob before scaling the fish to avoid inherited basis scaling
	reel_tween.tween_callback(func() -> void:
		rod_line.set_rope_length(rest_rope_length)
		bob.reparent(bob_start_position)
		_bob_set_rest()
	)
	reel_tween.tween_property(fish, "scale", Vector3(1.1, 1.1, 1.1), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	reel_tween.tween_property(fish, "scale", Vector3(0.01, 0.01, 0.01), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	reel_tween.finished.connect(func() -> void:
		if is_instance_valid(fish):
			fish.queue_free()
		reel_tween = null
	)

func _on_animator_animation_finished(anim_name):
	if anim_name == "Reel":
		input_buffer_timer = 0.0
