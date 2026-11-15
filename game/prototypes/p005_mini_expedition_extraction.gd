extends "res://game/prototypes/p004_gold_spill_theft.gd"
## P005 prototype controller: one short expedition from camp that ends only when the player
## chooses to extract there.
## Inherits, unchanged, P002's gold total, HUD, pouch, and pickup feedback, and P004's gold ledger
## and single thief encounter. P005 adds the camp extraction, a one-time results snapshot, and
## replay by scene reload. Nothing is kept between expeditions: there is no autoload or saved state.
## P004's 1 / 2 / 3 gold presets are not reachable here (see _unhandled_input), and P004's test
## status line is off in the P005 scene.
## Every value, position, and count is a Prototype Assumption, not final level or expedition design.

## Coin-name prefixes that group level gold for the printed summary, checked in this order.
## "BLure" coins count toward Branch B.
const AREAS: Array[String] = ["Camp", "TrailW", "TrailE", "A", "B"]
const AREA_LABELS: Dictionary = {
	"Camp": "camp", "TrailW": "west trail", "TrailE": "east trail", "A": "branch A", "B": "branch B"}

@export_group("Extraction")
## Horizontal distance from the camp centre inside which the interact input extracts.
## The camp disc is resized to match on start, so what the player sees is the real zone.
@export var extraction_radius: float = 2.5
## Seconds after extraction before keyboard or controller "accept" can press New Expedition, so
## the press that extracted cannot also skip the results.
@export var results_focus_delay: float = 0.5

var extracted: bool = false
## How many times this run has extracted. Must never exceed 1.
var extraction_count: int = 0
## Physics seconds since the expedition began. Shown only on the results panel.
var elapsed: float = 0.0
## Sum of every level pickup's value when the expedition began.
var level_total: int = 0
## One-time snapshot taken at extraction. Empty until then; never changed afterwards.
var results: Dictionary = {}

var _area_total: Dictionary = {}
var _area_collected: Dictionary = {}
var _using_pad: bool = false

@onready var _camp: Node3D = $Camp
@onready var _camp_disc: MeshInstance3D = $Camp/Disc
@onready var _prompt: Label = $HUD/ExtractPrompt
@onready var _results_layer: CanvasLayer = $Results
@onready var _secured_label: Label = $Results/Panel/Box/Secured
@onready var _lost_label: Label = $Results/Panel/Box/Lost
@onready var _left_label: Label = $Results/Panel/Box/Left
@onready var _time_label: Label = $Results/Panel/Box/Time
@onready var _new_button: Button = $Results/Panel/Box/NewExpedition


func _ready() -> void:
	super._ready()
	for area: String in AREAS:
		_area_total[area] = 0
		_area_collected[area] = 0
	for pickup: GoldPickup in $Gold.get_children():
		var area: String = _area_of(pickup.name)
		level_total += pickup.value
		_area_total[area] += pickup.value
		pickup.collected.connect(_on_area_collected.bind(area))
	var disc: CylinderMesh = _camp_disc.mesh
	disc.top_radius = extraction_radius
	disc.bottom_radius = extraction_radius
	_new_button.pressed.connect(new_expedition)
	# R also starts a new expedition from the results panel, where the paused controller gets no input.
	var restart := Shortcut.new()
	restart.events = InputMap.action_get_events("restart_test")
	_new_button.shortcut = restart
	_results_layer.visible = false
	_prompt.visible = in_camp()


func _input(event: InputEvent) -> void:
	# Only chooses which prompt wording to show.
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > 0.5):
		_using_pad = true
	elif event is InputEventKey or event is InputEventMouseButton:
		_using_pad = false


func _unhandled_input(event: InputEvent) -> void:
	# Deliberately does not call P004's handler: its 1 / 2 / 3 keys replace carried gold for trials.
	if event.is_action_pressed("interact"):
		try_extract()
	elif event.is_action_pressed("restart_test"):
		# During the expedition R abandons the run; nothing is secured.
		new_expedition()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	elapsed += delta
	_prompt.visible = in_camp()
	_prompt.text = ("A (bottom button)" if _using_pad else "E") + " — Secure haul and end expedition"


func in_camp() -> bool:
	return _flat_distance(_player.global_position, _camp.global_position) <= extraction_radius


## Ends the expedition if the King is inside camp. Returns true only for the one extraction that counts.
## Pausing the tree stops physics, pickups, spilled coins, and the thief, so no gold moves after the
## snapshot. Input is handled before physics in a frame, so a pickup or thief event cannot land
## between the snapshot and the pause.
func try_extract() -> bool:
	if extracted or not in_camp():
		return false
	extracted = true
	extraction_count += 1
	results = _snapshot()
	get_tree().paused = true
	_prompt.visible = false
	_show_results()
	_print_expedition()
	return true


## Starts a fresh expedition: every pickup, the thief, the King, the ledger, and the timer come back
## as authored because the whole scene is reloaded.
func new_expedition() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


## Level gold not yet collected, counted from the pickups' own collected signals.
func uncollected_level_gold() -> int:
	var collected: int = 0
	for area: String in AREAS:
		collected += _area_collected[area]
	return level_total - collected


## True when every unit of level gold is accounted for exactly once: P004's ledger (the haul always
## starts at 0 in P005) plus the gold still lying in the level.
func expedition_ok() -> bool:
	return ledger_ok() and haul_start == 0 and uncollected_level_gold() >= 0 \
		and gold_total + ground.size() + thief_held + lost + uncollected_level_gold() == level_total


## Belt and braces: after extraction the paused tree already stops spilled coins from being touched.
func _try_recover(coin: Node3D) -> bool:
	if extracted:
		return false
	return super._try_recover(coin)


func _on_area_collected(value: int, area: String) -> void:
	_area_collected[area] += value


func _snapshot() -> Dictionary:
	var by_area: Dictionary = {}
	for area: String in AREAS:
		by_area[area] = _area_collected[area]
	return {
		"secured": gold_total,
		# Gold the thief still holds when the King extracts is forfeited, like gold it escaped with.
		"lost_to_thief": lost + thief_held,
		"left_on_ground": ground.size(),
		"not_found": uncollected_level_gold(),
		"time": elapsed,
		"by_area": by_area,
	}


func _show_results() -> void:
	_secured_label.text = "Gold secured: %d" % results.secured
	_lost_label.text = "Lost to the thief: %d" % results.lost_to_thief
	_lost_label.visible = results.lost_to_thief > 0
	_left_label.text = "Left on the ground: %d" % results.left_on_ground
	_left_label.visible = results.left_on_ground > 0
	_time_label.text = "Time: %s" % _format_time(results.time)
	_results_layer.visible = true
	# Bound to the button, so it runs while paused and dies with the scene on reload.
	var focus: Tween = _new_button.create_tween()
	focus.tween_interval(results_focus_delay)
	focus.tween_callback(_new_button.grab_focus)


func _print_expedition() -> void:
	var parts: PackedStringArray = []
	for area: String in AREAS:
		parts.append("%s %d/%d" % [AREA_LABELS[area], results.by_area[area], _area_total[area]])
	print("P005 expedition | secured %d | lost to thief %d | left on ground %d | not found %d | %s | time %s" % [
		results.secured, results.lost_to_thief, results.left_on_ground, results.not_found,
		" | ".join(parts), _format_time(results.time)])


func _area_of(coin_name: String) -> String:
	for area: String in AREAS:
		if coin_name.begins_with(area):
			return area
	push_error("P005 coin %s has no area prefix" % coin_name)
	return "Camp"


func _format_time(seconds: float) -> String:
	var whole: int = int(seconds)
	return "%d:%02d" % [floori(seconds / 60.0), whole % 60]
