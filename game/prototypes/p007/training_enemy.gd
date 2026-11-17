extends CharacterBody3D
## P007 placeholder Training Enemy: Approach -> Windup -> Strike -> Recovery -> Approach, plus
## defeat. No species, lore, or canon.
## - Windup shows a floor telegraph drawn from the same reach and arc the strike tests. The strike
##   direction follows the King until commit_time, then locks (faint telegraph -> solid).
## - Each strike resolves against the King once, on first contact (Amendment A1): invulnerable
##   King = confirmed dodge, otherwise one hit. Either way that strike is spent.
## - No contact damage. Sword hits flash it but never interrupt it (no stagger).
## Every value is a P007 Prototype Assumption, not final enemy design.

const CombatSector := preload("res://game/prototypes/p007/combat_sector.gd")
const CombatKing := preload("res://game/prototypes/p007/combat_king.gd")

enum State { IDLE, APPROACH, WINDUP, STRIKE, RECOVERY, DEFEATED }
enum StrikeOutcome { NONE, HIT, DODGED }

## Keeps state boundaries stable against float accumulation of the physics delta.
const TIME_EPSILON: float = 0.00001

## Took one sword hit (health already reduced).
signal hit_taken
## Health reached zero.
signal defeated
signal state_changed
## The current strike resolved against the King (HIT or DODGED), once per strike.
signal strike_resolved(outcome: StrikeOutcome)

@export_group("Health")
## Sword hits needed to defeat the enemy.
@export var max_health: int = 3

@export_group("Movement")
## Seconds standing still before the first approach, so each attempt starts readably.
@export var start_delay: float = 1.0
## Approach speed in m/s (King walks at 5.0).
@export var move_speed: float = 3.0
## Ground distance to the King at which the enemy stops and starts its windup.
@export var attack_trigger_range: float = 1.5

@export_group("Strike")
## Seconds of telegraph before the strike.
@export var windup: float = 0.50
## Seconds into the windup at which the strike direction locks.
@export var commit_time: float = 0.25
## Seconds the strike can hit.
@export var strike_time: float = 0.15
## Seconds of standing still after the strike (the counterattack opening).
@export var recovery: float = 0.60
## Strike radius from the enemy's ground point, in meters.
@export var strike_reach: float = 1.8
## Total strike width in degrees.
@export var strike_arc_degrees: float = 90.0
## King health removed by one strike.
@export var damage: int = 1

## The King. Set in the P007 scene.
@export var king: Node3D

var health: int = 0
var state: State = State.IDLE
## Seconds in the current state.
var state_time: float = 0.0
## Strike direction on the ground plane; fixed once committed.
var strike_dir: Vector3 = Vector3.FORWARD
var committed: bool = false
var strike_outcome: StrikeOutcome = StrikeOutcome.NONE
## Windups begun / strikes that ran their full active window.
var attacks_started: int = 0
var attacks_completed: int = 0
var hits_landed: int = 0
var dodges_confirmed: int = 0
## Developer freeze (F4): the enemy stops acting so hit boundaries can be inspected.
var held: bool = false

var _telegraph: MeshInstance3D
var _telegraph_material: StandardMaterial3D

@onready var _visual: Sprite3D = $Visual
@onready var _health_label: Label3D = $HealthLabel
@onready var _collision: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	health = max_health
	# Exact ground point that the sword's arc test uses.
	CombatSector.add_indicator(self, "FootMarker", 0.1, 360.0, Color(1.0, 0.45, 0.4, 0.95), 0.025)
	_telegraph = CombatSector.add_indicator(self, "Telegraph", strike_reach, strike_arc_degrees, Color.WHITE, 0.03)
	_telegraph_material = _telegraph.material_override as StandardMaterial3D
	_telegraph.visible = false
	_update_health_label()


func is_alive() -> bool:
	return health > 0


func _physics_process(delta: float) -> void:
	if held or state == State.DEFEATED:
		return
	var k: CombatKing = king as CombatKing
	if k == null:
		return
	if k.is_defeated:
		if state != State.IDLE:
			_enter(State.IDLE)
		return
	state_time += delta
	match state:
		State.IDLE:
			if state_time + TIME_EPSILON >= start_delay:
				_enter(State.APPROACH)
		State.APPROACH:
			_approach(k)
		State.WINDUP:
			if not committed:
				_aim_at(k)
				if state_time + TIME_EPSILON >= commit_time:
					committed = true
			if state_time + TIME_EPSILON >= windup:
				_enter(State.STRIKE)
				_resolve_strike(k)
		State.STRIKE:
			if state_time + TIME_EPSILON >= strike_time:
				attacks_completed += 1
				_enter(State.RECOVERY)
			else:
				_resolve_strike(k)
		State.RECOVERY:
			if state_time + TIME_EPSILON >= recovery:
				_enter(State.APPROACH)
	_show_state()


func _approach(k: CombatKing) -> void:
	var offset: Vector3 = k.global_position - global_position
	offset.y = 0.0
	if offset.length() <= attack_trigger_range:
		velocity = Vector3.ZERO
		committed = false
		_aim_at(k)
		attacks_started += 1
		_enter(State.WINDUP)
		return
	velocity = offset.normalized() * move_speed
	move_and_slide()
	_visual.flip_h = offset.x < 0.0


func _aim_at(k: CombatKing) -> void:
	var offset: Vector3 = k.global_position - global_position
	offset.y = 0.0
	if offset.length() > 0.001:
		strike_dir = offset.normalized()
		_visual.flip_h = strike_dir.x < 0.0


## First contact decides the strike; afterwards this strike can neither hit nor be dodged again.
func _resolve_strike(k: CombatKing) -> void:
	if strike_outcome != StrikeOutcome.NONE:
		return
	if not CombatSector.contains(global_position, strike_dir, strike_reach, strike_arc_degrees, k.global_position):
		return
	match k.take_enemy_hit(damage):
		CombatKing.HitResult.HIT:
			strike_outcome = StrikeOutcome.HIT
			hits_landed += 1
		CombatKing.HitResult.DODGED:
			strike_outcome = StrikeOutcome.DODGED
			dodges_confirmed += 1
		_:
			return
	strike_resolved.emit(strike_outcome)


func _enter(next: State) -> void:
	state = next
	state_time = 0.0
	if next == State.STRIKE:
		strike_outcome = StrikeOutcome.NONE
	if is_alive():
		_visual.modulate = _rest_color()
	_show_state()
	state_changed.emit()


## Telegraph: faint while still aiming, solid once committed, bright during the strike.
func _show_state() -> void:
	_telegraph.rotation.y = CombatSector.yaw_for(strike_dir)
	match state:
		State.WINDUP:
			_telegraph.visible = true
			_telegraph_material.albedo_color = Color(1.0, 0.25, 0.15, 0.42) if committed else Color(1.0, 0.6, 0.2, 0.16)
		State.STRIKE:
			_telegraph.visible = true
			_telegraph_material.albedo_color = Color(1.0, 0.08, 0.05, 0.8)
		_:
			_telegraph.visible = false


## Sprite tint at rest: dimmed during recovery to show the opening.
func _rest_color() -> Color:
	return Color(0.62, 0.68, 0.8, 0.9) if state == State.RECOVERY else Color.WHITE


## Applies one sword hit. Returns false when the enemy is already defeated.
func take_sword_hit() -> bool:
	if not is_alive():
		return false
	health -= 1
	_update_health_label()
	hit_taken.emit()
	if health <= 0:
		_defeat()
	else:
		_flash(Color(1.0, 0.35, 0.3))
	return true


func _defeat() -> void:
	velocity = Vector3.ZERO
	_enter(State.DEFEATED)
	# The body no longer blocks the King once defeated.
	_collision.set_deferred("disabled", true)
	_visual.modulate = Color(0.35, 0.35, 0.38, 0.85)
	_health_label.text = "DEFEATED"
	defeated.emit()


func _flash(color: Color) -> void:
	_visual.modulate = color
	var tween: Tween = create_tween()
	tween.tween_property(_visual, "modulate", _rest_color(), 0.18)


func _update_health_label() -> void:
	_health_label.text = "●".repeat(maxi(health, 0)) + "○".repeat(maxi(max_health - health, 0))
