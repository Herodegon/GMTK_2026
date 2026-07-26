extends Node

enum CombatState { INACTIVE, ACTIVE }
enum PullDirection { LEFT = -1, NONE = 0, RIGHT = 1 }
var reel_actions: Array[StringName] = [
	"reel_up",
	"reel_left",
	"reel_down",
	"reel_right"
]

var current_fish: Node3D = null
var combat_state: CombatState = CombatState.INACTIVE
var pull_direction: PullDirection = PullDirection.NONE

func _ready() -> void:
	EventBus.start_fish_combat.connect(_on_start_fish_combat)
	EventBus.stop_fish_combat.connect(_on_stop_fish_combat)

func _input(event: InputEvent) -> void:
	if combat_state != CombatState.ACTIVE: return
	if  event is InputEventAction:

func _on_start_fish_combat(target_fish: Node3D) -> void:
	current_fish = target_fish
	combat_state = CombatState.ACTIVE