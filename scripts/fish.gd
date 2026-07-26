extends RigidBody3D

enum SwimState {
	IDLE,
	SEARCHING,
	FIGHTING
}

@onready var fish = preload("res://scenes/fish_caught.tscn")

@export var tether_point: Node3D = null
@export var tether_radius: float = 4.0
@export var combat_target_point: Node3D = null

@export_group("Swim Settings")
@export var impulse_strength: float = 1.0
@export var combat_impulse_strength: float = 5.0
@export var combat_target_offset_amount: float = 1.0
@export var combat_target_offset_max: float = 2.0
@export var turn_speed: float = 0.3
@export var friction: float = 0.1
@export var max_swim_cooldown: float = 3.0

var target_point: Vector3 = Vector3.ZERO
var swim_state: SwimState = SwimState.IDLE
var velocity: float = 0.0
var horizontal_offset_amount: float = 0.0
var swim_cooldown: float = 0.0

func _ready() -> void:
	EventBus.end_catch_event.connect(_on_end_catch_event)

func _physics_process(delta: float) -> void:
	match swim_state:
		SwimState.IDLE:
			swim_cooldown -= delta
			if target_point == Vector3.ZERO or global_position.distance_to(target_point) < 0.1 or swim_cooldown <= 0.0:
				target_point = _get_point_near_tether()
				velocity = impulse_strength * randf_range(0.15, 1.0)
				swim_cooldown = randf_range(1.0, max_swim_cooldown)
			_look_at_target(target_point, delta)
			var to_target := target_point - global_position
			to_target.y = 0.0
			move_and_collide(to_target.normalized() * velocity * delta)
			velocity = lerp(velocity, 0.0, friction * delta)
		SwimState.FIGHTING:
			_look_at_target(target_point, delta)
			var to_target := target_point - global_position
			to_target.y = 0.0
			move_and_collide(to_target.normalized() * velocity * delta)
			# Wander the offset sideways in the fish's LOCAL frame so it steers relative to heading
			horizontal_offset_amount += delta * randf_range(-combat_target_offset_amount, combat_target_offset_amount)
			horizontal_offset_amount = clampf(horizontal_offset_amount, -combat_target_offset_max, combat_target_offset_max)
			# Convert the local offset into world space using the fish's current orientation
			var world_offset := global_transform.basis * Vector3(horizontal_offset_amount, 0.0, 0.0)
			target_point = combat_target_point.global_position + world_offset


func _get_point_near_tether() -> Vector3:
	var random_angle = randf_range(0.0, TAU)
	var random_radius = randf_range(0.0, tether_radius)
	return tether_point.global_position + Vector3(cos(random_angle), 0.0, sin(random_angle)) * random_radius

func _look_at_target(target: Vector3, delta: float) -> void:
	var target_direction = (target - global_position).normalized()
	var target_angle = atan2(target_direction.x, target_direction.z)
	var new_angle = lerp_angle(rotation.y, target_angle, delta * turn_speed * TAU)
	rotation.y = new_angle

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_collision_layer_value(2): # is bob?
		var bob := area.get_parent()
		if not bob.try_claim(self):
			return
		swim_state = SwimState.FIGHTING
		global_position = bob.global_position
		target_point = combat_target_point.global_position
		velocity = combat_impulse_strength
		EventBus.start_catch_event.emit()

func _on_end_catch_event() -> void:
	if swim_state != SwimState.FIGHTING:
		return
	_reset_to_idle()

func _reset_to_idle() -> void:
	var f = fish.instantiate()
	f.scale = Vector3(0.25, 0.25, 0.25)
	get_parent().call_deferred("add_child", f)
	f.global_position = global_position
	
	horizontal_offset_amount = 0.0
	swim_cooldown = 0.0
	target_point = Vector3.ZERO

	var tween = get_tree().create_tween()
	tween.tween_property(self, "velocity", impulse_strength, 1.5)
	tween.finished.connect(func() -> void:
		swim_state = SwimState.IDLE
	)
	tween.play()
