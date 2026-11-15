extends Node3D
## P004 placeholder thief: one scripted encounter per reset, moving in straight lines inside an
## authored, obstacle-free zone. It owns its own states, movement, and visuals, and reports
## events by signal. It never changes gold: the P004 controller owns every gold transfer and
## tells the thief what it holds through set_holding().
## Prototype code; all values are exported Prototype Assumptions, not final enemy design.

enum State { IDLE, ALERT, APPROACH, PAUSE, GRAB, FLEE, GONE }

## Reached the King during APPROACH. The controller spills gold in response.
signal contacted
## Reached a landed spilled coin during GRAB. The controller decides whether the claim succeeds.
signal claim_attempted(coin: Node3D)
## The King reached the thief while it was fleeing with gold.
signal intercepted
## Arrived back at the burrow (escaped, or returned after giving up).
signal finished
## Any state change, so the test HUD can follow the thief without polling.
signal state_changed

@export_group("Timing")
## Seconds the warning shows before the thief starts moving.
@export var warn_time: float = 1.0
## Seconds of approach before the thief gives up and returns to its burrow.
@export var give_up_time: float = 8.0
## Seconds the thief stands still after contact, so the spill reads before the race for coins.
@export var pause_time: float = 0.5

@export_group("Speeds")
## m/s while approaching the King (King top speed is 5.0).
@export var approach_speed: float = 3.0
## m/s while heading for a spilled coin.
@export var grab_speed: float = 3.5
## m/s while returning to the burrow.
@export var flee_speed: float = 3.5

@export_group("Distances")
## Horizontal distance to the King that counts as contact.
@export var contact_radius: float = 0.8
## Horizontal distance to a coin at which the thief tries to claim it.
@export var claim_radius: float = 0.4
## Horizontal distance at which the King intercepts a fleeing, gold-carrying thief.
@export var intercept_radius: float = 1.0
## Distance to the burrow that counts as arriving.
@export var burrow_radius: float = 0.3

@export_group("Zone")
## The thief never leaves this XZ rectangle, so straight-line movement cannot cross walls.
@export var zone_min: Vector2 = Vector2(-3.0, -14.6)
@export var zone_max: Vector2 = Vector2(14.6, -7.4)

var state: State = State.IDLE
## Gold units the thief is carrying, as told by the controller. Drives the indicator and interception.
var holding: int = 0
## Set by the controller: the King, and the controller's live list of spilled coins on the ground.
var king: Node3D
var ground_coins: Array[Node3D] = []

var _home: Vector3
var _timer: float = 0.0

@onready var _alert: Label3D = $Alert
@onready var _carried: Sprite3D = $CarriedCoin
@onready var _visual: Sprite3D = $Visual


func _ready() -> void:
	_home = global_position
	reset()


## Back to the burrow, idle, empty-handed, and visible.
func reset() -> void:
	_enter(State.IDLE)
	global_position = _home
	visible = true
	_alert.visible = false
	_visual.modulate = Color.WHITE
	set_holding(0)


## Starts the encounter. Called by the controller when the King carries gold inside the trigger radius.
func notice() -> void:
	if state != State.IDLE:
		return
	_enter(State.ALERT)
	_alert.visible = true


func set_holding(amount: int) -> void:
	holding = amount
	_carried.visible = amount > 0


func home_position() -> Vector3:
	return _home


func _physics_process(delta: float) -> void:
	_timer += delta
	match state:
		State.ALERT:
			if _timer >= warn_time:
				_alert.visible = false
				_enter(State.APPROACH)
		State.APPROACH:
			_move_toward(king.global_position, approach_speed * delta)
			if _flat_distance(king.global_position) <= contact_radius:
				_enter(State.PAUSE)
				contacted.emit()
			elif _timer >= give_up_time:
				_enter(State.FLEE)
		State.PAUSE:
			if _timer >= pause_time:
				_enter(State.GRAB)
		State.GRAB:
			_grab_step(delta)
		State.FLEE:
			_move_toward(_home, flee_speed * delta)
			if holding > 0 and _flat_distance(king.global_position) <= intercept_radius:
				_flash()
				intercepted.emit()
			if _flat_distance(_home) <= burrow_radius:
				_enter(State.GONE)
				visible = false
				finished.emit()


func _grab_step(delta: float) -> void:
	var target: Node3D = _nearest_landed_coin()
	if target == null:
		# Nothing claimable: either everything was recovered, or coins are still landing.
		if ground_coins.is_empty():
			_enter(State.FLEE)
		return
	_move_toward(target.global_position, grab_speed * delta)
	if _flat_distance(target.global_position) <= claim_radius:
		claim_attempted.emit(target)
		# The controller answers synchronously through set_holding(). Leave with the coin, or
		# leave empty-handed if the claim was refused (theft cap) or nothing is left. If the
		# King took this coin first it is gone from the list, so keep looking.
		if holding > 0 or ground_coins.is_empty() or ground_coins.has(target):
			_enter(State.FLEE)


func _nearest_landed_coin() -> Node3D:
	var best: Node3D = null
	var best_d: float = INF
	for coin: Node3D in ground_coins:
		if not is_instance_valid(coin) or not coin.collectable:
			continue
		var d: float = _flat_distance(coin.global_position)
		if d < best_d:
			best_d = d
			best = coin
	return best


func _enter(next: State) -> void:
	state = next
	_timer = 0.0
	state_changed.emit()


func _move_toward(target: Vector3, step: float) -> void:
	var here := Vector2(global_position.x, global_position.z)
	var there := Vector2(target.x, target.z).clamp(zone_min, zone_max)
	here = here.move_toward(there, step)
	global_position = Vector3(here.x, global_position.y, here.y)
	if absf(there.x - here.x) > 0.01:
		# Art faces right; flip to face the direction of travel.
		_visual.flip_h = there.x < here.x


func _flat_distance(target: Vector3) -> float:
	return Vector2(global_position.x - target.x, global_position.z - target.z).length()


func _flash() -> void:
	_visual.modulate = Color(2.0, 0.6, 0.6)
	var tween: Tween = create_tween()
	tween.tween_property(_visual, "modulate", Color.WHITE, 0.25)
