extends "res://game/prototypes/p002_gold_collection.gd"
## P004 prototype controller: one thief encounter in the arena's north-east pocket.
## Reuses the P002 gold total, HUD, pouch, pickups, and reload reset unchanged, with no
## P003 wealth states or speed penalties (the King's speed never depends on gold here).
##
## This script is the single owner of every gold transfer in the encounter. At all times:
##   gold_total + coins on the ground + thief_held + lost == haul_start + level_collected
## Every transfer happens in one synchronous function that checks ownership first, so a
## spilled coin can be recovered or stolen at most once, and collection feedback only plays
## after the King has actually received the coin.
## All values are Prototype Assumptions for testing, not final balance or architecture.

const Thief := preload("res://game/prototypes/p004/thief.gd")
const SpillCoin := preload("res://game/prototypes/p004/spill_coin.gd")
const SPILL_COIN_SCENE := preload("res://game/prototypes/p004/spill_coin.tscn")

@export_group("Encounter")
## The thief notices the King when he carries gold and is within this distance of the burrow.
@export var trigger_radius: float = 9.0
## Most gold one contact can spill. Never more than the King carries.
@export var spill_cap: int = 3
## Most spilled coins the thief can claim per encounter.
@export var steal_cap: int = 1

@export_group("Spill")
## Distance from the King at which spilled coins land.
@export var spill_radius: float = 1.6
## Landing directions in degrees, measured from the King-to-thief direction, used in order.
## 60 / -60 land on the thief's side so its escape leads away from the King; 180 lands behind him.
@export var spill_angles: Array[float] = [60.0, -60.0, 180.0]
## Seconds a spilled or dropped coin takes to land. It cannot be collected until then.
@export var hop_time: float = 0.3
## Peak height of the hop in meters.
@export var hop_height: float = 0.6
## How far ahead of an intercepted thief its dropped coin lands, along its escape direction.
@export var drop_distance: float = 0.6
## Spilled and dropped coins are kept inside this XZ rectangle so they stay reachable.
@export var coin_min: Vector2 = Vector2(-2.6, -14.3)
@export var coin_max: Vector2 = Vector2(14.3, -7.7)

@export_group("Trial Presets")
## Carried gold set by the 1 / 2 / 3 trial keys.
@export var preset_gold: Array[int] = [0, 10, 20]

@export_group("Test HUD")
## Shows the encounter status line. Turn off for uncoached playtests; the gold counter stays.
@export var show_test_hud: bool = true

# Ledger. Only the transfer functions below change these.
var haul_start: int = 0
var level_collected: int = 0
var thief_held: int = 0
var lost: int = 0
var ground: Array[Node3D] = []

# Encounter record for the HUD and printed result.
var spilled: int = 0
var recovered: int = 0
var stolen: int = 0
var dropped: int = 0
var encounter_used: bool = false
var outcome: String = ""
var _no_gold_reported: bool = false

@onready var _player: CharacterBody3D = $Player
@onready var _thief: Thief = $Thief
@onready var _spill_root: Node3D = $SpillCoins
@onready var _spill_sound: AudioStreamPlayer = $SpillSound
@onready var _start_marker: Marker3D = $EncounterStart
@onready var _encounter_label: Label = $HUD/EncounterLabel


func _ready() -> void:
	super._ready()
	_thief.king = _player
	_thief.ground_coins = ground
	_thief.contacted.connect(_on_thief_contacted)
	_thief.claim_attempted.connect(_on_thief_claim_attempted)
	_thief.intercepted.connect(_on_thief_intercepted)
	_thief.finished.connect(_on_thief_finished)
	_thief.state_changed.connect(_update_encounter_label)
	_encounter_label.visible = show_test_hud
	_update_encounter_label()


func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)
	# The P003-named trial actions are reused as preset slots 1 / 2 / 3.
	if event.is_action_pressed("trial_light"):
		start_preset(preset_gold[0])
	elif event.is_action_pressed("trial_loaded"):
		start_preset(preset_gold[1])
	elif event.is_action_pressed("trial_heavy"):
		start_preset(preset_gold[2])


func _physics_process(_delta: float) -> void:
	if encounter_used or _thief.state != Thief.State.IDLE:
		return
	if _flat_distance(_player.global_position, _thief.home_position()) > trigger_radius:
		return
	if gold_total > 0:
		encounter_used = true
		outcome = ""
		_thief.notice()
		_update_encounter_label()
	elif not _no_gold_reported:
		# Nothing to steal: the thief stays idle and this does not use up the encounter.
		_no_gold_reported = true
		outcome = "no gold"
		_print_result()
		_update_encounter_label()


## True when every unit of the current test haul is accounted for exactly once.
func ledger_ok() -> bool:
	return gold_total >= 0 and thief_held >= 0 and lost >= 0 \
		and gold_total + ground.size() + thief_held + lost == haul_start + level_collected


## Level pickups (the P002 Gold node) are ordinary gold entering the haul.
func _on_gold_collected(value: int) -> void:
	level_collected += value
	super._on_gold_collected(value)
	_after_transfer()


## Transfer: ground -> King. Called by a spill coin before it gives any feedback.
func _try_recover(coin: Node3D) -> bool:
	if not ground.has(coin):
		return false
	ground.erase(coin)
	recovered += 1
	# P002 path: adds to the total, updates HUD and pouch, pulses, and plays the pickup sound.
	super._on_gold_collected(1)
	_after_transfer()
	return true


## Transfer: King -> ground, on contact.
func _on_thief_contacted() -> void:
	var amount: int = mini(spill_cap, gold_total)
	if amount <= 0:
		return
	gold_total -= amount
	spilled += amount
	var origin: Vector3 = _player.global_position
	var to_thief: Vector3 = _thief.global_position - origin
	to_thief.y = 0.0
	if to_thief.length() < 0.01:
		to_thief = Vector3.FORWARD
	to_thief = to_thief.normalized()
	for i in amount:
		var angle: float = deg_to_rad(spill_angles[i % spill_angles.size()])
		_spawn_ground_coin(origin, origin + to_thief.rotated(Vector3.UP, angle) * spill_radius)
	_spill_sound.play()
	_show_total()
	_after_transfer()


## Transfer: ground -> thief. Refused if the coin is already gone or the theft cap is reached.
func _on_thief_claim_attempted(coin: Node3D) -> void:
	if stolen >= steal_cap or not ground.has(coin):
		return
	ground.erase(coin)
	(coin as SpillCoin).take_by_thief()
	thief_held += 1
	stolen += 1
	_thief.set_holding(thief_held)
	_after_transfer()


## Transfer: thief -> ground, when the King intercepts the fleeing thief.
func _on_thief_intercepted() -> void:
	if thief_held <= 0:
		return
	var from: Vector3 = _thief.global_position
	var away: Vector3 = _thief.home_position() - from
	away.y = 0.0
	var land: Vector3 = from + (away.normalized() * drop_distance if away.length() > 0.01 else Vector3.ZERO)
	for i in thief_held:
		_spawn_ground_coin(from, land)
	dropped += thief_held
	thief_held = 0
	_thief.set_holding(0)
	_after_transfer()


## Transfer: thief -> lost, when it reaches the burrow still carrying gold. Ends the encounter.
func _on_thief_finished() -> void:
	lost += thief_held
	thief_held = 0
	_thief.set_holding(0)
	if lost > 0:
		outcome = "escaped with gold"
	elif dropped > 0:
		outcome = "intercepted"
	elif spilled > 0:
		outcome = "recovered before theft"
	else:
		outcome = "avoided"
	_after_transfer()
	_print_result()


## Starts a repeatable trial: new haul at `gold`, encounter and thief reset, King at the start.
## Level pickups keep their real state (collected ones stay gone); the new ledger starts here,
## so gold from earlier level pickups is replaced by the preset rather than carried over.
func start_preset(gold: int) -> void:
	for coin: Node3D in ground:
		if is_instance_valid(coin):
			coin.queue_free()
	ground.clear()
	gold_total = gold
	haul_start = gold
	level_collected = 0
	thief_held = 0
	lost = 0
	spilled = 0
	recovered = 0
	stolen = 0
	dropped = 0
	encounter_used = false
	outcome = ""
	_no_gold_reported = false
	_thief.reset()
	_player.global_position = _start_marker.global_position
	_player.velocity = Vector3.ZERO
	_show_total()
	_after_transfer()


func _show_total() -> void:
	super._show_total()
	if is_node_ready():
		_update_encounter_label()


func _spawn_ground_coin(from: Vector3, to: Vector3) -> void:
	var coin: SpillCoin = SPILL_COIN_SCENE.instantiate()
	coin.try_take = _try_recover
	_spill_root.add_child(coin)
	coin.apply_presentation(gold_presentation == Presentation.GROUNDED)
	var land := Vector3(clampf(to.x, coin_min.x, coin_max.x), 0.0, clampf(to.z, coin_min.y, coin_max.y))
	coin.scatter(Vector3(from.x, 0.0, from.z), land, hop_time, hop_height)
	ground.append(coin)


func _after_transfer() -> void:
	assert(ledger_ok(), "P004 gold ledger out of balance")
	_update_encounter_label()


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func _status_text() -> String:
	if outcome != "":
		return outcome
	match _thief.state:
		Thief.State.IDLE:
			return "waiting"
		Thief.State.ALERT:
			return "noticed you!"
		Thief.State.APPROACH:
			return "approaching"
		Thief.State.PAUSE, Thief.State.GRAB:
			return "grabbing"
		Thief.State.FLEE:
			return "fleeing with gold" if thief_held > 0 else "fleeing"
	return ""


func _summary() -> String:
	return "start %d | level +%d | spilled %d | recovered %d | stolen %d | dropped %d | lost %d | carried %d | on ground %d" % [
		haul_start, level_collected, spilled, recovered, stolen, dropped, lost, gold_total, ground.size()]


func _print_result() -> void:
	print("P004 trial | %s | %s" % [outcome, _summary()])


func _update_encounter_label() -> void:
	_encounter_label.text = "Thief: %s\nSpilled %d | recovered %d | stolen %d | dropped %d | lost %d" % [
		_status_text(), spilled, recovered, stolen, dropped, lost]
