extends "res://game/player/player.gd"
## P007 Gold King: P001 movement plus eight-direction movement-based facing and one directional
## sword swing (windup, active, recovery) whose direction is locked when the swing starts, one
## directional dodge with a brief invulnerable interval, and health.
## A dodge may cancel only the last part of sword recovery.
## Movement: each physics tick takes exactly one path. Walking calls super._physics_process()
## once (P001's velocity, its single move_and_slide(), and the left/right sprite flip); dodging
## calls move_and_slide() once itself and skips super. Godot 4 does not run the parent's
## _physics_process on its own, so movement never happens twice. player.gd/.tscn are unchanged.
## The camera never yaws (P001 camera), so world-plane input is also camera-relative.
## Iteration 1 (Mode B only, `focus_available`): an optional target focus on the single enemy.
## While focused, the direction toward the enemy (instead of movement input) chooses the facing,
## through the same eight-direction snap. Movement, sword, and dodge rules are otherwise unchanged:
## the swing still snapshots facing at its start, and a neutral dodge still uses the current facing.
## Every value is a P007 Prototype Assumption, not final combat design.

const CombatSector := preload("res://game/prototypes/p007/combat_sector.gd")
const TrainingEnemy := preload("res://game/prototypes/p007/training_enemy.gd")

enum AttackPhase { IDLE, WINDUP, ACTIVE, RECOVERY }
## Result of an enemy strike reaching the King.
enum HitResult { HIT, DODGED, IGNORED }

## Keeps phase boundaries stable against float accumulation of the physics delta.
const TIME_EPSILON: float = 0.00001

## A swing passed its timing check and started.
signal swing_started
## The active window touched the opponent (once per swing at most).
signal sword_hit(target: Node3D)
## A dodge started; `canceled_attack` is true when it cut a swing's late recovery short.
signal dodge_started(canceled_attack: bool)
## An enemy strike reached the King while invulnerable (one per strike).
signal dodge_confirmed
## An enemy strike damaged the King (health already reduced).
signal damaged
## Health reached zero.
signal defeated
## Focus was acquired (`reason` is "") or released (`reason` is one of the FOCUS_RELEASE_* values).
signal focus_changed(focused: bool, reason: String)

## Facing index 6 is screen-up (world -Z); indices step 45 degrees from +X toward +Z.
const FACING_UP: int = 6
const FREE_CUE_COLOR: Color = Color(1.0, 0.85, 0.25, 0.55)
const FOCUS_CUE_COLOR: Color = Color(0.3, 0.95, 1.0, 0.75)

## Why focus ended. Logged per attempt so the A/B comparison can tell them apart.
const FOCUS_RELEASE_PRESS: String = "press"
const FOCUS_RELEASE_RANGE: String = "range"
const FOCUS_RELEASE_DEFEAT: String = "defeat"
const FOCUS_RELEASE_INVALID: String = "invalid"
const FOCUS_RELEASE_KING_DEFEATED: String = "king_defeated"
## Below this ground distance the bearing to the target is meaningless; facing is kept as is.
const FOCUS_MIN_OFFSET: float = 0.05
## A swing counts as a retreat-swing when the movement input points away from the opponent this much.
const RETREAT_DOT: float = -0.3

@export_group("Facing")
## Minimum input length (after the action deadzone) that may change facing. Absorbs stick drift.
@export var facing_deadzone: float = 0.35

@export_group("Sword")
## Total width of the frontal arc, in degrees.
@export var sword_arc_degrees: float = 110.0
## Arc radius from the King's ground point, in meters. The opponent's ground point must be inside.
@export var sword_reach: float = 1.4
## Seconds before the arc can hit.
@export var sword_windup: float = 0.08
## Seconds the arc can hit.
@export var sword_active: float = 0.12
## Seconds after the active window before another swing may start.
@export var sword_recovery: float = 0.20

@export_group("Dodge")
## Ground distance covered by one unobstructed dodge, in meters.
@export var dodge_distance: float = 1.75
## Seconds a dodge lasts.
@export var dodge_duration: float = 0.20
## Invulnerability starts this many seconds after the dodge starts...
@export var iframe_start: float = 0.04
## ...and ends at this many seconds (exclusive).
@export var iframe_end: float = 0.16
## Seconds from the START of one dodge until the next may begin.
@export var dodge_cooldown: float = 0.70
## A dodge may cancel a swing only when this many seconds (or fewer) of recovery remain.
@export var dodge_cancel_window: float = 0.10

@export_group("Health")
## Enemy hits the King can take.
@export var max_health: int = 3

@export_group("Target Focus")
## Mode B. When false (Mode A, the original baseline) the target_focus action is ignored entirely.
@export var focus_available: bool = false
## Ground distance within which a focus press acquires the opponent, in meters.
@export var focus_acquire_range: float = 7.0
## Ground distance beyond which focus releases on its own. Larger than the acquire range so focus
## does not drop and return repeatedly near one boundary.
@export var focus_release_range: float = 9.0

## The one opponent the sword can hit. Set in the P007 scene.
@export var opponent: Node3D

## 0..7: 0 right, 1 down-right, 2 down, 3 down-left, 4 left, 5 up-left, 6 up, 7 up-right.
var facing_index: int = FACING_UP
var facing_dir: Vector3 = direction_for_index(FACING_UP)

var attack_phase: AttackPhase = AttackPhase.IDLE
## Facing captured when the swing started. Turning mid-swing never changes it.
var attack_dir: Vector3 = Vector3.ZERO
## Seconds since the current swing started.
var attack_elapsed: float = 0.0
var swings: int = 0

var health: int = 0
var is_defeated: bool = false
var dodging: bool = false
var dodge_dir: Vector3 = Vector3.ZERO
## Seconds since the current dodge started (counted after each dodge tick's movement).
var dodge_elapsed: float = 0.0
var dodge_cooldown_left: float = 0.0
var dodges: int = 0
var cancels: int = 0

## True while focus is held on `focus_target` (Mode B only).
var focused: bool = false
var focus_target: Node3D = null
var focus_acquisitions: int = 0
## Releases counted by FOCUS_RELEASE_* reason.
var focus_releases: Dictionary = {
	FOCUS_RELEASE_PRESS: 0, FOCUS_RELEASE_RANGE: 0, FOCUS_RELEASE_DEFEAT: 0,
	FOCUS_RELEASE_INVALID: 0, FOCUS_RELEASE_KING_DEFEATED: 0,
}
## Seconds spent focused (physics time).
var focused_time: float = 0.0

## Comparison counters. Each "_focused" value counts the subset that happened while focused, so
## the unfocused share is the total minus it. A swing (and its hit) belongs to the focus state at
## the moment the swing started; a dodge to the state when it started; damage to the state when
## it landed. Retreat-swings started while the movement input pointed away from the opponent.
var swings_focused: int = 0
var sword_hits: int = 0
var sword_hits_focused: int = 0
var dodges_focused: int = 0
var hits_taken: int = 0
var hits_taken_focused: int = 0
var retreat_swings: int = 0
var retreat_swings_focused: int = 0
var retreat_hits: int = 0
var retreat_hits_focused: int = 0

## Movement input read this tick; used to classify retreat-swings.
var _input: Vector2 = Vector2.ZERO
## The current swing was started while focused / while retreating.
var _swing_focused: bool = false
var _swing_retreat: bool = false

## Targets already hit by the current swing (one hit per target per swing).
var _hit_this_swing: Array[Node3D] = []
var _facing_cue: MeshInstance3D
var _sword_arc: MeshInstance3D
var _sword_material: StandardMaterial3D


func _ready() -> void:
	health = max_health
	# Exact ground point that every hit and strike test uses.
	CombatSector.add_indicator(self, "FootMarker", 0.1, 360.0, Color(1.0, 0.95, 0.6, 0.95), 0.025)
	_facing_cue = CombatSector.add_indicator(self, "FacingCue", 0.75, 30.0, FREE_CUE_COLOR, 0.02)
	# Facing up, the cue lies behind the King's own billboard; draw it on top so all 8 read.
	(_facing_cue.material_override as StandardMaterial3D).no_depth_test = true
	_facing_cue.material_override.render_priority = 1
	_apply_facing_cue()
	_sword_arc = CombatSector.add_indicator(self, "SwordArc", sword_reach, sword_arc_degrees, Color.WHITE, 0.04)
	_sword_material = _sword_arc.material_override as StandardMaterial3D
	_sword_arc.visible = false


func _physics_process(delta: float) -> void:
	if is_defeated:
		return
	# Order per tick: advance timers, read input, start actions, move once, then resolve hits.
	dodge_cooldown_left = maxf(dodge_cooldown_left - delta, 0.0)
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_input = input
	# Focus first, so a focus press and an attack press on the same tick swing at the target.
	if focus_available and Input.is_action_just_pressed("target_focus"):
		toggle_focus()
	validate_focus()
	_advance_attack(delta)
	if focused:
		# Every tick, dodging included, so the first attack after a dodge uses a current bearing.
		update_facing_toward_target()
	elif not dodging:
		update_facing_from_input(input)
	if not dodging:
		if Input.is_action_just_pressed("dodge"):
			try_dodge(input)
		if not dodging and Input.is_action_just_pressed("attack"):
			try_attack()
	if dodging:
		_dodge_step(delta)
	else:
		super._physics_process(delta)
	if attack_phase == AttackPhase.ACTIVE:
		_resolve_sword_hits()
	# A defeating hit releases focus on the same tick.
	validate_focus()
	if focused:
		focused_time += delta


## Starts a swing along the current facing. Ignored unless the previous swing has fully ended.
func try_attack() -> bool:
	if attack_phase != AttackPhase.IDLE or dodging or is_defeated:
		return false
	attack_dir = facing_dir
	attack_elapsed = 0.0
	attack_phase = AttackPhase.WINDUP
	_hit_this_swing.clear()
	swings += 1
	_swing_focused = focused
	_swing_retreat = _is_retreating()
	if _swing_focused:
		swings_focused += 1
	if _swing_retreat:
		retreat_swings += 1
		if _swing_focused:
			retreat_swings_focused += 1
	_sword_arc.rotation.y = CombatSector.yaw_for(attack_dir)
	_show_arc()
	swing_started.emit()
	return true


## Starts a dodge along the input (or the facing when input is neutral). Rejected while dodging,
## on cooldown, defeated, or during windup, active, and early recovery. In late recovery the
## swing is cancelled first: its arc and hit record are cleared and it cannot hit again.
func try_dodge(input: Vector2) -> bool:
	if dodging or is_defeated or dodge_cooldown_left > TIME_EPSILON:
		return false
	if attack_phase == AttackPhase.WINDUP or attack_phase == AttackPhase.ACTIVE:
		return false
	var canceled: bool = false
	if attack_phase == AttackPhase.RECOVERY:
		if recovery_left() > dodge_cancel_window + TIME_EPSILON:
			return false
		_end_attack()
		cancels += 1
		canceled = true
	if input.length() >= facing_deadzone:
		dodge_dir = Vector3(input.x, 0.0, input.y).normalized()
	else:
		dodge_dir = facing_dir
	dodging = true
	dodge_elapsed = 0.0
	dodge_cooldown_left = dodge_cooldown
	dodges += 1
	if focused:
		dodges_focused += 1
	dodge_started.emit(canceled)
	return true


func is_invulnerable() -> bool:
	return dodging and dodge_elapsed + TIME_EPSILON >= iframe_start and dodge_elapsed + TIME_EPSILON < iframe_end


## Called by the enemy once per strike, on first contact. Invulnerable: the strike is dodged.
func take_enemy_hit(amount: int) -> HitResult:
	if is_defeated:
		return HitResult.IGNORED
	if is_invulnerable():
		dodge_confirmed.emit()
		return HitResult.DODGED
	health = maxi(health - amount, 0)
	hits_taken += 1
	if focused:
		hits_taken_focused += 1
	damaged.emit()
	if health == 0:
		_defeat()
	else:
		_flash(Color(1.0, 0.3, 0.25))
	return HitResult.HIT


func _dodge_step(delta: float) -> void:
	velocity = dodge_dir * (dodge_distance / dodge_duration)
	move_and_slide()
	dodge_elapsed += delta
	if dodge_elapsed + TIME_EPSILON >= dodge_duration:
		dodging = false
		# Hand back to walking from rest so the dodge covers its set distance, not more.
		velocity = Vector3.ZERO
		_visual.modulate = Color.WHITE
	# Opaque tints only: the King's sprite uses alpha-cut, so translucency would hide him entirely.
	elif is_invulnerable():
		_visual.modulate = Color(0.45, 0.8, 1.0)
	else:
		_visual.modulate = Color(0.75, 0.9, 1.0)


func _end_attack() -> void:
	attack_phase = AttackPhase.IDLE
	_hit_this_swing.clear()
	_show_arc()


func _defeat() -> void:
	is_defeated = true
	dodging = false
	velocity = Vector3.ZERO
	_end_attack()
	if focused:
		release_focus(FOCUS_RELEASE_KING_DEFEATED)
	_visual.modulate = Color(0.4, 0.4, 0.42)
	defeated.emit()


func _flash(color: Color) -> void:
	_visual.modulate = color
	var tween: Tween = create_tween()
	tween.tween_property(_visual, "modulate", Color.WHITE, 0.2)


func attack_total() -> float:
	return sword_windup + sword_active + sword_recovery


## Seconds of recovery remaining; only meaningful during RECOVERY.
func recovery_left() -> float:
	return attack_total() - attack_elapsed


func _advance_attack(delta: float) -> void:
	if attack_phase == AttackPhase.IDLE:
		return
	attack_elapsed += delta
	attack_phase = _phase_at(attack_elapsed)
	_show_arc()


func _phase_at(elapsed: float) -> AttackPhase:
	if elapsed + TIME_EPSILON < sword_windup:
		return AttackPhase.WINDUP
	if elapsed + TIME_EPSILON < sword_windup + sword_active:
		return AttackPhase.ACTIVE
	if elapsed + TIME_EPSILON < attack_total():
		return AttackPhase.RECOVERY
	return AttackPhase.IDLE


func _resolve_sword_hits() -> void:
	var enemy: TrainingEnemy = opponent as TrainingEnemy
	if enemy == null or not enemy.is_alive() or _hit_this_swing.has(enemy):
		return
	if CombatSector.contains(global_position, attack_dir, sword_reach, sword_arc_degrees, enemy.global_position):
		_hit_this_swing.append(enemy)
		sword_hits += 1
		if _swing_focused:
			sword_hits_focused += 1
		if _swing_retreat:
			retreat_hits += 1
			if _swing_focused:
				retreat_hits_focused += 1
		enemy.take_sword_hit()
		sword_hit.emit(enemy)


## Faint during windup, bright while it can hit, hidden in recovery: the cue matches hit timing.
func _show_arc() -> void:
	match attack_phase:
		AttackPhase.WINDUP:
			_sword_arc.visible = true
			_sword_material.albedo_color = Color(1.0, 1.0, 0.85, 0.22)
		AttackPhase.ACTIVE:
			_sword_arc.visible = true
			_sword_material.albedo_color = Color(1.0, 0.95, 0.55, 0.7)
		_:
			_sword_arc.visible = false


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
		# Cyan while focused, gold otherwise: the cue itself says which facing rule applies.
		_facing_cue_material().albedo_color = FOCUS_CUE_COLOR if focused else FREE_CUE_COLOR


func _facing_cue_material() -> StandardMaterial3D:
	return _facing_cue.material_override as StandardMaterial3D


# --- Iteration 1: target focus (Mode B) ---

## Press handling: releases when focused, otherwise tries to acquire. Returns true if state changed.
## Ignored in Mode A and once the King is defeated. A failed acquisition does nothing.
func toggle_focus() -> bool:
	if not focus_available or is_defeated:
		return false
	if focused:
		release_focus(FOCUS_RELEASE_PRESS)
		return true
	if not _focus_candidate_ok(opponent) or ground_distance_to(opponent) > focus_acquire_range + TIME_EPSILON:
		return false
	focused = true
	focus_target = opponent
	focus_acquisitions += 1
	update_facing_toward_target()
	focus_changed.emit(true, "")
	return true


func release_focus(reason: String) -> void:
	if not focused:
		return
	focused = false
	focus_target = null
	focus_releases[reason] = int(focus_releases.get(reason, 0)) + 1
	# Facing keeps its last direction until movement input changes it, as with neutral input.
	_apply_facing_cue()
	focus_changed.emit(false, reason)


## Releases focus when the target was removed, defeated, or moved beyond the release range.
func validate_focus() -> void:
	if not focused:
		return
	if not is_instance_valid(focus_target) or not focus_target.is_inside_tree():
		release_focus(FOCUS_RELEASE_INVALID)
	elif focus_target.has_method("is_alive") and not focus_target.call("is_alive"):
		release_focus(FOCUS_RELEASE_DEFEAT)
	elif ground_distance_to(focus_target) > focus_release_range + TIME_EPSILON:
		release_focus(FOCUS_RELEASE_RANGE)


## Snaps the bearing to the focused target to one of the same eight facings movement uses.
func update_facing_toward_target() -> void:
	if not focused or not is_instance_valid(focus_target):
		return
	var to: Vector3 = focus_target.global_position - global_position
	var flat_to: Vector2 = Vector2(to.x, to.z)
	if flat_to.length() < FOCUS_MIN_OFFSET:
		return
	facing_index = snap_index(flat_to)
	facing_dir = direction_for_index(facing_index)
	_apply_facing_cue()
	# Sprite faces the target side; straight up/down keeps the last flip (same threshold as P001).
	if facing_dir.x >= facing_threshold:
		_visual.flip_h = false
	elif facing_dir.x <= -facing_threshold:
		_visual.flip_h = true


## While focused the sprite follows the target, not the movement direction (P001 flips by movement).
func _update_facing(horizontal_input: float) -> void:
	if focused:
		return
	super._update_facing(horizontal_input)


func ground_distance_to(node: Node3D) -> float:
	var gap: Vector3 = node.global_position - global_position
	return Vector2(gap.x, gap.z).length()


## Untyped on purpose: a freed opponent must be rejected here, not fail a typed-argument check.
func _focus_candidate_ok(node: Variant) -> bool:
	if not is_instance_valid(node) or not (node as Node3D).is_inside_tree():
		return false
	return not node.has_method("is_alive") or bool(node.call("is_alive"))


func _is_retreating() -> bool:
	if _input.length() < facing_deadzone or not is_instance_valid(opponent):
		return false
	var gap: Vector3 = opponent.global_position - global_position
	var away: Vector2 = Vector2(gap.x, gap.z)
	if away.length() < FOCUS_MIN_OFFSET:
		return false
	return _input.normalized().dot(away.normalized()) < RETREAT_DOT
