extends Node3D
## P006 playable camp hub: the King's humble camp, the treasury, the merchant stall once
## recruited, and the departure point. Reads and changes persistent state only through the
## session. No construction, upkeep, workers, or settlement economy.
## Placeholder layout and visuals; every value is a Prototype Assumption.

const Session := preload("res://game/prototypes/p006_meaningful_extraction_rewards.gd")

## Horizontal distance within which the interact input reaches the departure point or the stall.
@export var interact_radius: float = 2.2
## Seconds after opening the shop before keyboard or controller "accept" can press a button, so
## the press that opened it cannot also buy.
@export var shop_focus_delay: float = 0.3
## Seconds the arrival message stays on screen.
@export var notice_time: float = 5.0
## Treasury balances at which each hoard pile beside the chest appears (spendable gold, so piles
## shrink again after a purchase).
@export var hoard_thresholds: Array[int] = [1, 10, 20]

## Set by the session before this node enters the tree. Null when the scene is run on its own.
var session: Session = null
var shop_open: bool = false

var _using_pad: bool = false

@onready var _player: CharacterBody3D = $Player
@onready var _departure: Node3D = $Departure
@onready var _stall: Node3D = $Stall
@onready var _hoard: Node3D = $Treasury/Hoard
@onready var _chest_caption: Label3D = $Treasury/Caption
@onready var _treasury_label: Label = $HUD/TreasuryLabel
@onready var _prompt: Label = $HUD/Prompt
@onready var _notice: Label = $HUD/Notice
@onready var _sword_label: Label = $HUD/SwordLabel
@onready var _shop: CanvasLayer = $Shop
@onready var _balance_label: Label = $Shop/Panel/Box/Balance
@onready var _item_label: Label = $Shop/Panel/Box/Item
@onready var _status_label: Label = $Shop/Panel/Box/Status
@onready var _buy_button: Button = $Shop/Panel/Box/Buy
@onready var _close_button: Button = $Shop/Panel/Box/Close
@onready var _purchase_sound: AudioStreamPlayer = $PurchaseSound


func _ready() -> void:
	_shop.visible = false
	_buy_button.pressed.connect(buy_sword)
	_close_button.pressed.connect(close_shop)
	var cancel := Shortcut.new()
	cancel.events = InputMap.action_get_events("ui_cancel")
	_close_button.shortcut = cancel
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


func near_stall() -> bool:
	return _stall.visible and _flat_distance(_player.global_position, _stall.global_position) <= interact_radius


func near_departure() -> bool:
	return _flat_distance(_player.global_position, _departure.global_position) <= interact_radius


## The single interact press handler, so one press is never used by two things.
func interact() -> void:
	if shop_open:
		return
	if near_stall():
		open_shop()
	elif near_departure():
		depart()


func depart() -> bool:
	return session != null and session.depart(self)


## Pauses the camp while the one-item shop is open; the shop layer keeps processing.
func open_shop() -> bool:
	if shop_open or not near_stall():
		return false
	shop_open = true
	_status_label.text = ""
	_refresh_shop()
	_shop.visible = true
	_prompt.visible = false
	get_tree().paused = true
	_buy_button.release_focus()
	_close_button.release_focus()
	# Bound to the shop layer, so it runs while paused and dies with the scene.
	var focus: Tween = _close_button.create_tween()
	focus.tween_interval(shop_focus_delay)
	focus.tween_callback(_focus_shop)
	return true


func close_shop() -> void:
	if not shop_open:
		return
	shop_open = false
	# A hidden button must not keep keyboard focus in camp.
	_buy_button.release_focus()
	_close_button.release_focus()
	_shop.visible = false
	get_tree().paused = false
	refresh()


## The only purchase path. The session checks affordability and ownership and spends exactly once.
func buy_sword() -> bool:
	if not shop_open or session == null:
		return false
	var bought: bool = session.try_buy_sword()
	if bought:
		_status_label.text = "The First Sword is yours. Take it on your next expedition."
		_purchase_sound.play()
	refresh()
	_refresh_shop()
	_focus_shop()
	return bought


## Re-reads persistent state into the treasury and stall visuals.
func refresh() -> void:
	var gold: int = treasury()
	_treasury_label.text = "Treasury: %d" % gold
	_chest_caption.text = "Treasury\n%d gold" % gold
	for i in _hoard.get_child_count():
		(_hoard.get_child(i) as Node3D).visible = i < hoard_thresholds.size() and gold >= hoard_thresholds[i]
	_stall.visible = session != null and session.merchant_recruited
	_sword_label.visible = session != null and session.sword_owned


func hoard_stage() -> int:
	var stage: int = 0
	for pile: Node in _hoard.get_children():
		if (pile as Node3D).visible:
			stage += 1
	return stage


func _update_prompt() -> void:
	var key: String = "A" if _using_pad else "E"
	if shop_open:
		_prompt.visible = false
	elif near_stall():
		_prompt.text = key + " — Visit the merchant"
		_prompt.visible = true
	elif near_departure():
		_prompt.text = key + " — Depart on an expedition"
		_prompt.visible = true
	else:
		_prompt.visible = false


func _refresh_shop() -> void:
	var gold: int = treasury()
	var price: int = session.sword_price if session != null else 0
	_item_label.text = "%s — %d gold" % [Session.SWORD_NAME, price]
	_balance_label.text = "Your treasury: %d gold" % gold
	if session != null and session.sword_owned:
		_buy_button.text = "Owned"
		_buy_button.disabled = true
	elif session != null and session.can_buy_sword():
		_buy_button.text = "Buy (%d gold)" % price
		_buy_button.disabled = false
	else:
		_buy_button.text = "Not enough gold (need %d more)" % maxi(price - gold, 0)
		_buy_button.disabled = true


func _focus_shop() -> void:
	if not shop_open:
		return
	if _buy_button.disabled:
		_close_button.grab_focus()
	else:
		_buy_button.grab_focus()


func _show_notice(text: String) -> void:
	_notice.text = text
	_notice.visible = true
	var tween: Tween = _notice.create_tween()
	tween.tween_interval(notice_time)
	tween.tween_callback(_notice.hide)


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
