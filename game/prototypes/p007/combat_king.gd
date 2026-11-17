extends "res://game/player/player.gd"
## P007 Gold King: P001 movement plus eight-direction movement-based facing.
## Movement still comes from player.gd: this script calls super._physics_process() once per
## physics tick, so P001's velocity, single move_and_slide(), and left/right sprite flip run
## exactly once. player.gd and player.tscn are not modified.
## The camera never yaws (P001 camera), so world-plane input is also camera-relative.
## Every value is a P007 Prototype Assumption, not final combat design.

const CombatSector := preload("res://game/prototypes/p007/combat_sector.gd")

## Facing index 6 is screen-up (world -Z); indices step 45 degrees from +X toward +Z.
const FACING_UP: int = 6

@export_group("Facing")
## Minimum input length (after the action deadzone) that may change facing. Absorbs stick drift.
@export var facing_deadzone: float = 0.35

## 0..7: 0 right, 1 down-right, 2 down, 3 down-left, 4 left, 5 up-left, 6 up, 7 up-right.
var facing_index: int = FACING_UP
var facing_dir: Vector3 = direction_for_index(FACING_UP)

var _facing_cue: MeshInstance3D


func _ready() -> void:
	# Exact ground point that every hit and strike test uses.
	CombatSector.add_indicator(self, "FootMarker", 0.1, 360.0, Color(1.0, 0.95, 0.6, 0.95), 0.025)
	_facing_cue = CombatSector.add_indicator(self, "FacingCue", 0.75, 30.0, Color(1.0, 0.85, 0.25, 0.55), 0.02)
	_apply_facing_cue()


func _physics_process(delta: float) -> void:
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	update_facing_from_input(input)
	super._physics_process(delta)


## Snaps intentional input to one of eight facings. Input below facing_deadzone keeps the last facing.
func update_facing_from_input(input: Vector2) -> void:
	if input.length() < facing_deadzone:
		return
	facing_index = snap_index(input)
	facing_dir = direction_for_index(facing_index)
	_apply_facing_cue()


## Nearest of eight 45-degree directions; input.y is screen-down (world +Z).
static func snap_index(input: Vector2) -> int:
	return posmod(roundi(atan2(input.y, input.x) / (PI / 4.0)), 8)


static func direction_for_index(index: int) -> Vector3:
	var angle: float = float(index) * PI / 4.0
	return Vector3(cos(angle), 0.0, sin(angle)).normalized()


func _apply_facing_cue() -> void:
	if _facing_cue != null:
		_facing_cue.rotation.y = CombatSector.yaw_for(facing_dir)
