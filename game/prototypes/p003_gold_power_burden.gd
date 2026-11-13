extends "res://game/prototypes/p002_gold_collection.gd"
## P003 prototype controller. Reuses the P002 gold total, HUD, pouch, and pickups unchanged,
## and adds three provisional wealth states that set the King's top speed and strike impact.
## Also runs the timed course (start -> target -> gate -> finish), trial presets, and results.
## All values are Prototype Assumptions for testing, not final balance or architecture.

const PlayerScript := preload("res://game/player/player.gd")
const Strike := preload("res://game/prototypes/p003/strike.gd")
const TestTarget := preload("res://game/prototypes/p003/test_target.gd")
const TimedGate := preload("res://game/prototypes/p003/timed_gate.gd")

enum Wealth { LIGHT, LOADED, HEAVY }
enum Trial { IDLE, READY, RUNNING, FINISHED }

const WEALTH_NAMES: Array[String] = ["Light", "Loaded", "Heavy"]

@export_group("Wealth States")
## Gold at which the King becomes Loaded.
@export var loaded_at: int = 6
## Gold at which the King becomes Heavy.
@export var heavy_at: int = 14
## Top speed per state in m/s. Only top speed changes; acceleration, turning, and collision do not.
@export var light_speed: float = 5.0
@export var loaded_speed: float = 4.6
@export var heavy_speed: float = 4.2
## Strike impact per state. Against toughness 6 this gives 3 / 2 / 1 hits.
@export var light_impact: int = 2
@export var loaded_impact: int = 3
@export var heavy_impact: int = 6

@export_group("Trial Presets")
## Gold set by the 1 / 2 / 3 trial keys.
@export var light_preset_gold: int = 0
@export var loaded_preset_gold: int = 10
@export var heavy_preset_gold: int = 20
## Gold the scene starts with after a full reset (R).
@export var start_gold: int = 0

@export_group("Course")
## When off, the course target is removed so trials measure movement and gate timing only.
@export var course_target_enabled: bool = true
## Shows the Light / Loaded / Heavy line in the trial HUD.
@export var show_wealth_state: bool = true

var wealth: Wealth = Wealth.LIGHT
var trial: Trial = Trial.IDLE
var trial_ticks: int = 0
## Gate clock. Held at 0 while a trial is ready, then runs continuously (also after finishing,
## so the gate keeps cycling and the King can always walk back out).
var gate_ticks: int = 0
var target_broken_tick: int = -1
var strike_attempts: int = 0
var strike_hits: int = 0
var gate_wait_ticks: int = 0
var practice_hits_last_break: int = 0

@onready var _player: PlayerScript = $Player
@onready var _strike: Strike = $Player/Strike
@onready var _course_target: TestTarget = $Course/CourseTarget
@onready var _practice_target: TestTarget = $PracticeTarget
@onready var _gate: TimedGate = $Course/Gate
@onready var _start_marker: Marker3D = $Course/StartMarker
@onready var _trial_label: Label = $HUD/TrialLabel
@onready var _lane_start_x: float = ($Course/StartLine as Node3D).global_position.x
@onready var _lane_finish_x: float = ($Course/FinishLine as Node3D).global_position.x


func _ready() -> void:
	gold_total = start_gold
	super._ready()
	_strike.attempted.connect(_on_strike_attempted)
	_course_target.struck.connect(_on_course_target_struck)
	_practice_target.struck.connect(_on_practice_target_struck)
	_reset_course()
	trial = Trial.IDLE


func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)
	if event.is_action_pressed("trial_light"):
		_start_preset(light_preset_gold)
	elif event.is_action_pressed("trial_loaded"):
		_start_preset(loaded_preset_gold)
	elif event.is_action_pressed("trial_heavy"):
		_start_preset(heavy_preset_gold)


func _physics_process(_delta: float) -> void:
	var pos: Vector3 = _player.global_position
	var in_lane: bool = pos.z < _start_marker.global_position.z + 1.2
	match trial:
		Trial.IDLE, Trial.FINISHED:
			# Walking up to the lane entrance arms a new trial without any key press.
			if in_lane and pos.x > _lane_start_x and pos.x < _lane_start_x + 3.0:
				_reset_course()
		Trial.READY:
			if in_lane and pos.x < _lane_start_x:
				trial = Trial.RUNNING
		Trial.RUNNING:
			trial_ticks += 1
			if _gate.is_closed and in_lane and pos.x > _gate.global_position.x and pos.x < _gate.global_position.x + 1.5:
				gate_wait_ticks += 1
			if in_lane and pos.x < _lane_finish_x:
				trial = Trial.FINISHED
				_print_result()
	if trial != Trial.READY:
		gate_ticks += 1
	_gate.set_trial_time(_ticks_to_seconds(gate_ticks))
	_update_trial_label()


## Updates HUD and pouch (P002), then applies the wealth state for the new total.
func _show_total() -> void:
	super._show_total()
	_apply_wealth()
	_update_trial_label()


func wealth_for(total: int) -> Wealth:
	if total >= heavy_at:
		return Wealth.HEAVY
	if total >= loaded_at:
		return Wealth.LOADED
	return Wealth.LIGHT


func _apply_wealth() -> void:
	wealth = wealth_for(gold_total)
	_player.move_speed = [light_speed, loaded_speed, heavy_speed][wealth]
	_strike.impact = [light_impact, loaded_impact, heavy_impact][wealth]


func _start_preset(gold: int) -> void:
	gold_total = gold
	_show_total()
	_player.global_position = _start_marker.global_position
	_player.velocity = Vector3.ZERO
	_reset_course()


func _reset_course() -> void:
	trial = Trial.READY
	trial_ticks = 0
	gate_ticks = 0
	target_broken_tick = -1
	strike_attempts = 0
	strike_hits = 0
	gate_wait_ticks = 0
	if course_target_enabled:
		_course_target.restore()
	else:
		_course_target.remove()
	_practice_target.restore()
	_gate.set_trial_time(0.0)
	_update_trial_label()


func _on_strike_attempted() -> void:
	if trial == Trial.RUNNING:
		strike_attempts += 1


func _on_course_target_struck(broke: bool) -> void:
	if trial != Trial.RUNNING:
		return
	strike_hits += 1
	if broke:
		target_broken_tick = trial_ticks


func _on_practice_target_struck(broke: bool) -> void:
	if broke:
		practice_hits_last_break = _practice_target.hits_taken


func _ticks_to_seconds(ticks: int) -> float:
	return float(ticks) / float(Engine.physics_ticks_per_second)


func _trial_summary() -> String:
	var broken_text: String = "removed" if not course_target_enabled else (
		"%.2f s" % _ticks_to_seconds(target_broken_tick) if target_broken_tick >= 0 else "—")
	return "time %.2f s | target broken at %s | strikes %d (hits %d) | gate wait %.2f s" % [
		_ticks_to_seconds(trial_ticks), broken_text, strike_attempts, strike_hits,
		_ticks_to_seconds(gate_wait_ticks)]


func _print_result() -> void:
	print("P003 trial | %s | gold %d | speed %.1f m/s | impact %d | %s" % [
		WEALTH_NAMES[wealth], gold_total, _player.move_speed, _strike.impact, _trial_summary()])


func _update_trial_label() -> void:
	var lines: Array[String] = []
	if show_wealth_state:
		lines.append("%s | speed %.1f m/s | impact %d" % [WEALTH_NAMES[wealth], _player.move_speed, _strike.impact])
	match trial:
		Trial.READY:
			lines.append("Course: ready")
		Trial.RUNNING:
			lines.append("Course: %.2f s" % _ticks_to_seconds(trial_ticks))
		Trial.FINISHED:
			lines.append("Finished: " + _trial_summary())
	if practice_hits_last_break > 0:
		lines.append("Practice target: broke in %d hit(s)" % practice_hits_last_break)
	_trial_label.text = "\n".join(lines)
