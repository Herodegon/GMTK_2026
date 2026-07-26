extends RigidBody3D

enum SwimState {
	IDLE,
	SEARCHING,
	FIGHTING
}

@export var tether_point: Node3D = null
@export var tether_radius: float = 4.0
@export var combat_target_point: Node3D = null

@export_group("Swim Settings")
@export var impulse_strength: float = 1.0
@export var combat_impulse_strength: float = 5.0
@export var combat_weave_speed: float = 2.0 # how fast the fish weaves side to side
@export var combat_target_offset_max: float = 0.2 # max sideways weave amplitude
@export var turn_speed: float = 0.3
@export var friction: float = 0.1
@export var max_swim_cooldown: float = 3.0
@export var reel_speed: float = 4.0 # how fast queued reel distance is consumed (m/s)

var target_point: Vector3 = Vector3.ZERO
var swim_state: SwimState = SwimState.IDLE
var velocity: float = 0.0
var combat_weave_phase: float = 0.0
var swim_cooldown: float = 0.0

var reel_target: Node3D = null # what the fish is being pulled toward
var reel_remaining: float = 0.0 # queued pull distance not yet travelled
var is_caught: bool = false # true once won; the rod owns this fish until it frees it

func _ready() -> void:
	EventBus.win_catch_event.connect(_on_win_catch_event)
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
			# Struggle: swim toward the (wandering) fight target
			var to_target := target_point - global_position
			to_target.y = 0.0
			var motion := to_target.normalized() * velocity * delta
			# Reel: consume a fixed queued distance smoothly toward the pull target
			if reel_remaining > 0.0 and reel_target:
				var step := minf(reel_remaining, reel_speed * delta)
				var reel_dir := reel_target.global_position - global_position
				reel_dir.y = 0.0
				motion += reel_dir.normalized() * step
				reel_remaining -= step
			move_and_collide(motion)
			combat_weave_phase += delta * combat_weave_speed
			var weave := sin(combat_weave_phase) * combat_target_offset_max
			# Apply in the fish's LOCAL frame so the weave is relative to its heading
			var world_offset := global_transform.basis * Vector3(weave, 0.0, 0.0)
			target_point = combat_target_point.global_position + world_offset

## Queues a fixed pull distance toward target. Each press adds distance that is
## then eased in over subsequent frames, so pulling is framerate-independent.
func reel_in(target: Node3D, distance: float) -> void:
	reel_target = target
	reel_remaining += distance

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
		target_point = combat_target_point.global_position
		combat_weave_phase = randf() * TAU # desync weave between fish
		velocity = combat_impulse_strength
		EventBus.start_catch_event.emit()
		EventBus.send_fish.emit(self)

func _on_win_catch_event(fish: Node3D) -> void:
	if fish != self:
		return
	# Hand ownership to the rod's reel animation: stop moving ourselves so we don't
	# fight the position tween or touch freed nodes while being reeled in and freed.
	is_caught = true
	set_physics_process(false)
	freeze = true
	$CatchRadius.set_collision_mask_value(3, false)

func _on_end_catch_event() -> void:
	if is_caught: # the rod is reeling us in and will free us; don't reset
		return
	if swim_state != SwimState.FIGHTING:
		return
	_reset_to_idle()

func _reset_to_idle() -> void:
	combat_weave_phase = 0.0
	swim_cooldown = 0.0
	target_point = Vector3.ZERO
	reel_remaining = 0.0
	reel_target = null

	var tween = create_tween()
	tween.tween_property(self, "velocity", impulse_strength, 1.5)
	tween.finished.connect(func() -> void:
		swim_state = SwimState.IDLE
	)
	tween.play()
