extends "res://game/prototypes/p005_mini_expedition_extraction.gd"
## P006 expedition: the P005 expedition, unchanged underneath, run inside the P006 session.
## Adds: an optional merchant in Branch A whose recruitment is confirmed only by extracting,
## depositing the extracted haul into the session treasury exactly once, results that show
## the treasury before and after, a "Continue to Camp" exit instead of an automatic new run, and
## R as an explicit abandon that secures nothing.
## The P005 scene and script are not modified; P006 overrides only the hooks listed here.
## Run on its own (F6, no session) it falls back to P005's reload behavior for quick checks.
## Every value and position is a Prototype Assumption, not final design.

const Session := preload("res://game/prototypes/p006_meaningful_extraction_rewards.gd")
const Merchant := preload("res://game/prototypes/p006/merchant.gd")

## Set by the session before this node enters the tree. Null when the scene is run on its own.
var session: Session = null
## The session run this expedition belongs to; sent with the deposit so a stale scene cannot pay.
var run_id: int = 0
var treasury_before: int = 0
var treasury_after: int = 0
## True once the session accepted this run's deposit.
var deposited: bool = false
## Met the merchant on this run. Pending until extraction; discarded if the run is abandoned.
var merchant_met: bool = false

@onready var _abandon_hint: Label = $HUD/AbandonHint
@onready var _treasury_label: Label = $Results/Panel/Box/Treasury
@onready var _not_found_label: Label = $Results/Panel/Box/NotFound
@onready var _merchant_label: Label = $Results/Panel/Box/MerchantNews
@onready var _merchant: Merchant = $Merchant


func _ready() -> void:
	super._ready()
	if session != null:
		run_id = session.run_id
		treasury_before = session.treasury
	treasury_after = treasury_before
	# Once recruited, the merchant lives at camp and is not found on the road again.
	_merchant.visible = session == null or not session.merchant_recruited
	# In P006, R only ever means "abandon"; the results panel is left with the explicit button.
	_new_button.shortcut = null
	_new_button.text = "Continue to Camp"
	var box: Node = _new_button.get_parent()
	for label: Label in _result_lines():
		box.move_child(label, _new_button.get_index())
		label.visible = false
	_update_hints()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()
	elif event.is_action_pressed("restart_test"):
		# Abandon: nothing is secured. new_expedition() routes it to the session.
		new_expedition()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_hints()


## The single interact press handler, so one press is never used by two things.
func interact() -> void:
	if can_meet_merchant():
		meet_merchant()
	else:
		try_extract()


func can_meet_merchant() -> bool:
	return _merchant.visible and not merchant_met and not extracted and _merchant.in_reach(_player.global_position)


## Meeting costs nothing and ignores carried gold.
func meet_merchant() -> bool:
	if not can_meet_merchant():
		return false
	merchant_met = _merchant.mark_met()
	return merchant_met


## P005 extraction plus the P006 deposit. The deposit uses the snapshot P005 took, so it equals
## the gold actually carried at extraction, and the session refuses a second deposit for this run.
func try_extract() -> bool:
	if not super.try_extract():
		return false
	if session != null:
		deposited = session.complete_expedition(run_id, results.secured, results.merchant_met)
		treasury_after = session.treasury
	# The tree is paused now, so physics will not refresh the hints.
	_update_hints()
	_show_treasury()
	_print_p006()
	return true


## Replaces P005's reload. After extraction it returns to camp; before extraction it abandons.
## Both the results button and R arrive here.
func new_expedition() -> void:
	if session == null:
		super.new_expedition()
	elif extracted:
		session.finish_expedition(self)
	else:
		session.abandon_expedition(self)


func _snapshot() -> Dictionary:
	var snap: Dictionary = super._snapshot()
	snap["merchant_met"] = merchant_met
	return snap


func _show_results() -> void:
	super._show_results()
	_not_found_label.text = "Never picked up: %d" % results.not_found
	_not_found_label.visible = results.not_found > 0
	_merchant_label.visible = results.merchant_met


## P006 prints its own line after the deposit instead of P005's line.
func _print_expedition() -> void:
	pass


func _result_lines() -> Array[Label]:
	return [_treasury_label, _not_found_label, _merchant_label]


func _show_treasury() -> void:
	_treasury_label.visible = session != null
	_treasury_label.text = "Treasury: %d + %d = %d" % [treasury_before, results.secured, treasury_after]


func _update_hints() -> void:
	_abandon_hint.visible = not extracted
	_abandon_hint.text = ("Back" if _using_pad else "R") + " — Abandon expedition (carried gold is lost)"
	if can_meet_merchant():
		_prompt.visible = true
		_prompt.text = ("A (bottom button)" if _using_pad else "E") + " — Invite the merchant to your camp"


func _print_p006() -> void:
	print("P006 expedition | run %d | secured %d | treasury %d -> %d | deposited %s | lost to thief %d | left on ground %d | not found %d | merchant %s | thief %s | time %s" % [
		run_id, results.secured, treasury_before, treasury_after, "yes" if deposited else "no",
		results.lost_to_thief, results.left_on_ground, results.not_found,
		"met" if results.merchant_met else ("recruited earlier" if session != null and session.merchant_recruited and not results.merchant_met else "not met"),
		outcome if outcome != "" else "not finished", _format_time(results.time)])
