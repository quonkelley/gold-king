extends Node
## P006 prototype session root: owns the state that survives between expeditions in one play
## session (treasury, merchant recruitment, sword ownership) and shows exactly one playable child,
## the camp hub or an expedition. Children receive `session` before they enter the tree and ask
## this node to change scenes; they never change scenes themselves.
## Nothing is saved to disk: quitting the game resets everything.
## This is a prototype scene split, not world/scene architecture. Every value is a Prototype Assumption.

const HUB_PATH := "res://game/prototypes/p006/camp_hub.tscn"
const EXPEDITION_PATH := "res://game/prototypes/p006/expedition.tscn"
const SWORD_NAME := "First Sword"
const ABANDON_NOTICE := "Expedition abandoned — nothing was secured."

## Secured gold the merchant asks for the sword.
@export var sword_price: int = 20

## Secured, spendable gold. Only complete_expedition() adds to it and only try_buy_sword() spends it.
var treasury: int = 0
var merchant_recruited: bool = false
var sword_owned: bool = false
## Identity of the current or most recent expedition. Increases on every departure.
var run_id: int = 0
## True from departure until that run deposits or is abandoned. A closed run can never deposit.
var run_open: bool = false
## Counters for tests and the printed log.
var deposit_count: int = 0
var purchase_count: int = 0
## Message the hub shows on arrival, then clears.
var camp_notice: String = ""
## The playable child currently shown.
var current: Node = null

var _switching: bool = false


func _ready() -> void:
	_swap_to(HUB_PATH)


## Called by the hub's departure point. Starts a fresh expedition with nothing carried.
func depart(from: Node) -> bool:
	if not _can_switch(from):
		return false
	run_id += 1
	run_open = true
	camp_notice = ""
	_request(EXPEDITION_PATH)
	return true


## Called by an expedition once its results have been acknowledged. The deposit already happened.
func finish_expedition(from: Node) -> bool:
	if not _can_switch(from):
		return false
	_request(HUB_PATH)
	return true


## Called by an expedition the player leaves without extracting. Nothing is deposited, and the
## run's pending merchant discovery is discarded with the expedition instance.
func abandon_expedition(from: Node) -> bool:
	if not _can_switch(from):
		return false
	if run_open:
		run_open = false
		camp_notice = ABANDON_NOTICE
	_request(HUB_PATH)
	return true


## The one place secured gold enters the treasury. Refuses a stale run, a second deposit for
## the same run, and an abandoned run, so repeated input can never pay twice. Returns whether the deposit was applied.
func complete_expedition(from_run: int, secured: int, met_merchant: bool) -> bool:
	if from_run != run_id or not run_open or secured < 0:
		return false
	run_open = false
	var before: int = treasury
	treasury += secured
	deposit_count += 1
	var lines: PackedStringArray = ["Secured %d gold — treasury %d → %d." % [secured, before, treasury]]
	if met_merchant and not merchant_recruited:
		merchant_recruited = true
		lines.append("The merchant has arrived and set up a stall!")
	camp_notice = "\n".join(lines)
	return true


func can_buy_sword() -> bool:
	return not sword_owned and treasury >= sword_price


## Spends exactly sword_price once. Refused when already owned or unaffordable; never goes negative.
func try_buy_sword() -> bool:
	if not can_buy_sword():
		return false
	var before: int = treasury
	treasury -= sword_price
	sword_owned = true
	purchase_count += 1
	print("P006 purchase | %s | price %d | treasury %d -> %d | owned yes" % [SWORD_NAME, sword_price, before, treasury])
	return true


func _can_switch(from: Node) -> bool:
	return not _switching and from != null and from == current


func _request(path: String) -> void:
	_switching = true
	# Deferred: the request usually comes from a button or input handler inside the child being freed.
	_swap_to.call_deferred(path)


func _swap_to(path: String) -> void:
	# Extraction and the shop pause the tree; the next scene must start unpaused.
	get_tree().paused = false
	if current != null:
		remove_child(current)
		current.queue_free()
	var packed: PackedScene = load(path)
	var next: Node = packed.instantiate()
	next.set("session", self)
	current = next
	add_child(next)
	_switching = false
