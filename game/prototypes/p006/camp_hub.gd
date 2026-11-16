extends Node3D
## P006 playable camp hub: the King's humble camp, the treasury, the merchant stall once
## recruited, and the departure point. Reads and changes persistent state only through the
## session. No construction, upkeep, workers, or settlement economy.
## Placeholder layout and visuals; every value is a Prototype Assumption.

const Session := preload("res://game/prototypes/p006_meaningful_extraction_rewards.gd")

## Horizontal distance within which the interact input reaches the departure point or the stall.
@export var interact_radius: float = 2.2
## Seconds the arrival message stays on screen.
@export var notice_time: float = 5.0
## Treasury balances at which each hoard pile beside the chest appears (spendable gold, so piles
## shrink again after a purchase).
@export var hoard_thresholds: Array[int] = [1, 10, 20]

## Set by the session before this node enters the tree. Null when the scene is run on its own.
var session: Session = null

var _using_pad: bool = false

@onready var _player: CharacterBody3D = $Player
@onready var _departure: Node3D = $Departure
@onready var _stall: Node3D = $Stall
@onready var _hoard: Node3D = $Treasury/Hoard
@onready var _chest_caption: Label3D = $Treasury/Caption
@onready var _treasury_label: Label = $HUD/TreasuryLabel
@onready var _prompt: Label = $HUD/Prompt
@onready var _notice: Label = $HUD/Notice


func _ready() -> void:
	refresh()
	_notice.visible = false
	if session != null and session.camp_notice != "":
		_show_notice(session.camp_notice)
		session.camp_notice = ""
	_update_prompt()


func _input(event: InputEvent) -> void:
	# Only chooses which prompt wording to show.
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > 0.5):
		_using_pad = true
	elif event is InputEventKey or event is InputEventMouseButton:
		_using_pad = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()


func _physics_process(_delta: float) -> void:
	_update_prompt()


func treasury() -> int:
	return session.treasury if session != null else 0


func near_departure() -> bool:
	return _flat_distance(_player.global_position, _departure.global_position) <= interact_radius


## The single interact press handler, so one press is never used by two things.
func interact() -> void:
	if near_departure():
		depart()


func depart() -> bool:
	return session != null and session.depart(self)


## Re-reads persistent state into the treasury and stall visuals.
func refresh() -> void:
	var gold: int = treasury()
	_treasury_label.text = "Treasury: %d" % gold
	_chest_caption.text = "Treasury\n%d gold" % gold
	for i in _hoard.get_child_count():
		(_hoard.get_child(i) as Node3D).visible = i < hoard_thresholds.size() and gold >= hoard_thresholds[i]
	_stall.visible = session != null and session.merchant_recruited


func hoard_stage() -> int:
	var stage: int = 0
	for pile: Node in _hoard.get_children():
		if (pile as Node3D).visible:
			stage += 1
	return stage


func _update_prompt() -> void:
	var key: String = "A" if _using_pad else "E"
	if near_departure():
		_prompt.text = key + " — Depart on an expedition"
		_prompt.visible = true
	else:
		_prompt.visible = false


func _show_notice(text: String) -> void:
	_notice.text = text
	_notice.visible = true
	var tween: Tween = _notice.create_tween()
	tween.tween_interval(notice_time)
	tween.tween_callback(_notice.hide)


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
