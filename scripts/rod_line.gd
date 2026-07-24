extends Node3D

@export_group("Start and End Points")
@export var start_node: Node3D = null
@export var target_node: Node3D = null

@export_group("Rope Settings")
@export var constraint: float = 0.5
@export var constraint_iterations: int = 2
@export var dampening: float = 0.9
@export var gravity: Vector3 = Vector3.DOWN * 9.81
@export var segment_color: Color = Color.WHITE
@export var payout_speed: float = 32.0

var position_list: PackedVector3Array = PackedVector3Array()
var prev_position_list: PackedVector3Array = PackedVector3Array()
var position_locked_list: PackedInt32Array = PackedInt32Array()

var _current_length: float = 0.0
var _target_length: float = 0.0
var _segment_length: float = 0.25

@onready var line_mesh: MeshInstance3D = $LineMesh
@onready var _im: ImmediateMesh = line_mesh.mesh as ImmediateMesh
var _material: StandardMaterial3D = StandardMaterial3D.new()
var render_line: bool = true

func _ready() -> void:
	_material.albedo_color = segment_color
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.vertex_color_use_as_albedo = true

func _physics_process(delta: float) -> void:
	if render_line and position_list.size() > 0:
		_advance_payout(delta)
		_update_points(delta)
		for i in range(constraint_iterations):
			_update_constraints()
		_draw_line()

# Snap the rope to a length instantly (use for the resting/idle state).
func set_rope_length(length: float) -> void:
	_build_rope(length)
	_current_length = length
	_target_length = length
	_segment_length = _current_length / float(max(position_list.size() - 1, 1))

# Pay the line out (or reel it in) smoothly toward a length over time.
func extend_rope_to(length: float) -> void:
	# Allocate enough segments for the final length now so we never reallocate
	# mid-flight, but keep the current effective length so it grows gradually.
	var keep_length := _current_length
	_build_rope(length)
	_target_length = length
	_current_length = keep_length

func _advance_payout(delta: float) -> void:
	_current_length = move_toward(_current_length, _target_length, payout_speed * delta)
	_segment_length = _current_length / float(max(position_list.size() - 1, 1))

func _build_rope(length: float) -> void:
	var num_segments: int = max(int(length / constraint), 2)
	position_list.resize(num_segments)
	prev_position_list.resize(num_segments)
	position_locked_list.resize(num_segments)

	var a := start_node.global_position
	var b := target_node.global_position
	for i in range(num_segments):
		# Spread points along the start->target line so they never bundle up.
		var t := float(i) / float(num_segments - 1)
		var p := a.lerp(b, t)
		position_list[i] = p
		prev_position_list[i] = p
		if i == 0 or i == num_segments - 1:
			position_locked_list[i] = true
		else:
			position_locked_list[i] = false

func _update_points(delta: float) -> void:
	for i in range(position_list.size()):
		var current := position_list[i]
		var previous := prev_position_list[i]
		var velocity := (current - previous) * dampening
		prev_position_list[i] = current
		if !bool(position_locked_list[i]):
			position_list[i] = current + velocity + gravity * delta * delta
		else:
			position_list[i] = current

func _update_constraints() -> void:
	position_list[0] = start_node.global_position
	position_list[position_list.size() - 1] = target_node.global_position

	for i in range(position_list.size() - 1):
		var a := position_list[i]
		var b := position_list[i + 1]
		var dist := (b - a).length()
		if dist == 0.0:
			continue
		var diff := (dist - _segment_length) / dist
		var offset := (b - a) * diff * 0.5

		var a_locked := bool(position_locked_list[i])
		var b_locked := bool(position_locked_list[i + 1])

		if a_locked and b_locked:
			continue
		elif a_locked:
			position_list[i + 1] -= offset * 2.0
		elif b_locked:
			position_list[i] += offset * 2.0
		else:
			position_list[i] += offset
			position_list[i + 1] -= offset

func _draw_line() -> void:
	_im.clear_surfaces()
	_im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, _material)
	for p in position_list:
		_im.surface_add_vertex(line_mesh.to_local(p))
	_im.surface_end()
