extends "res://game/prototypes/p005_mini_expedition_extraction.gd"
## P006 expedition: the P005 expedition, unchanged underneath, run inside the P006 session.
## Adds: an optional merchant in Branch A whose recruitment is confirmed only by extracting;
## the First Sword (once bought) and two breakable containers that release bonus gold;
## depositing the extracted haul into the session treasury exactly once; results that show the
## treasury before and after and all gold left behind; a "Continue to Camp" exit instead of an
## automatic new run; and R as an explicit abandon that secures nothing.
## The P005 scene and script are not modified; P006 overrides only the hooks listed here.
## Run on its own (F6, no session) it falls back to P005's reload behavior for quick checks.
## Every value and position is a Prototype Assumption, not final design.
##
## Gold accounting. The 25 standard pickups and P004's ledger are unchanged. Bonus coins are
## tracked separately only while loose (bonus_ground, which the thief never targets). Collecting
## one runs the normal P004 collection path, so once carried it is ordinary gold and every spill,
## theft, recovery, and loss uses P004's transfers. P004's `level_collected` therefore means all
## world gold that entered the haul, standard plus bonus. P006 invariant, every frame:
##   gold_total + ground + thief_held + lost + uncollected standard + loose bonus == 25 + bonus_generated

const Session := preload("res://game/prototypes/p006_meaningful_extraction_rewards.gd")
const Merchant := preload("res://game/prototypes/p006/merchant.gd")
const Sword := preload("res://game/prototypes/p006/sword.gd")
const TreasureContainer := preload("res://game/prototypes/p006/treasure_container.gd")

@export_group("Sword Loot")
## Bonus gold each container releases when the sword opens it.
@export var bonus_per_container: int = 3
## Distance from the container at which bonus coins land.
@export var bonus_scatter_radius: float = 1.1
## Landing directions in degrees around the container (0 = toward the camera), used in order.
@export var bonus_scatter_angles: Array[float] = [0.0, 120.0, 240.0]

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

# Bonus-gold record. Only _on_container_broke_open and _try_take_bonus change these.
var bonus_generated: int = 0
var bonus_collected: int = 0
var bonus_ground: Array[Node3D] = []
var containers_broken: int = 0

@onready var _abandon_hint: Label = $HUD/AbandonHint
@onready var _attack_hint: Label = $HUD/AttackHint
@onready var _treasury_label: Label = $Results/Panel/Box/Treasury
@onready var _not_found_label: Label = $Results/Panel/Box/NotFound
@onready var _bonus_label: Label = $Results/Panel/Box/Bonus
@onready var _merchant_label: Label = $Results/Panel/Box/MerchantNews
@onready var _merchant: Merchant = $Merchant
@onready var _sword: Sword = $Player/Sword
@onready var _containers: Node3D = $Containers
@onready var _bonus_root: Node3D = $BonusCoins


func _ready() -> void:
	super._ready()
	if session != null:
		run_id = session.run_id
		treasury_before = session.treasury
	treasury_after = treasury_before
	# Once recruited, the merchant lives at camp and is not found on the road again.
	_merchant.visible = session == null or not session.merchant_recruited
	_sword.owned = session != null and session.sword_owned
	for container: TreasureContainer in _containers.get_children():
		container.broke_open.connect(_on_container_broke_open)
	# In P006, R only ever means "abandon"; the results panel is left with the explicit button.
	_new_button.shortcut = null
	_new_button.text = "Continue to Camp"
	# Treasury right under "Gold secured"; the other P006 lines just above the time.
	var box: Node = _new_button.get_parent()
	box.move_child(_treasury_label, _secured_label.get_index() + 1)
	for label: Label in [_bonus_label, _not_found_label, _merchant_label]:
		box.move_child(label, _time_label.get_index())
	for label: Label in _result_lines():
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


## P005's expedition check with bonus gold added. P005's own version stays exact for P005.
func expedition_ok() -> bool:
	return ledger_ok() and haul_start == 0 and uncollected_level_gold() >= 0 \
		and bonus_generated == bonus_collected + bonus_ground.size() \
		and bonus_generated <= _containers.get_child_count() * bonus_per_container \
		and gold_total + ground.size() + thief_held + lost + uncollected_level_gold() + bonus_ground.size() \
			== level_total + bonus_generated


## Transfer: container -> loose bonus coins. A container opens at most once (its own guard).
func _on_container_broke_open(container: Node3D) -> void:
	if extracted:
		return
	containers_broken += 1
	var origin: Vector3 = container.global_position
	for i in bonus_per_container:
		var angle: float = deg_to_rad(bonus_scatter_angles[i % bonus_scatter_angles.size()])
		_spawn_bonus_coin(origin, origin + Vector3(sin(angle), 0.0, cos(angle)) * bonus_scatter_radius)
	assert(expedition_ok(), "P006 gold accounting out of balance")


## Transfer: loose bonus coin -> King, through the normal P004/P002 collection path.
## Called by the coin before it gives any feedback.
func _try_take_bonus(coin: Node3D) -> bool:
	if extracted or not bonus_ground.has(coin):
		return false
	bonus_ground.erase(coin)
	bonus_collected += 1
	_on_gold_collected(1)
	return true


func _spawn_bonus_coin(from: Vector3, to: Vector3) -> void:
	var coin: SpillCoin = SPILL_COIN_SCENE.instantiate()
	coin.try_take = _try_take_bonus
	_bonus_root.add_child(coin)
	coin.apply_presentation(gold_presentation == Presentation.GROUNDED)
	coin.scatter(Vector3(from.x, 0.0, from.z), Vector3(to.x, 0.0, to.z), hop_time, hop_height)
	bonus_ground.append(coin)
	bonus_generated += 1


## Loose bonus coins (including any still hopping, frozen by the pause) are reported, never deposited.
func _snapshot() -> Dictionary:
	var snap: Dictionary = super._snapshot()
	snap["merchant_met"] = merchant_met
	snap["standard_collected"] = level_total - snap.not_found
	snap["bonus_generated"] = bonus_generated
	snap["bonus_collected"] = bonus_collected
	snap["bonus_left"] = bonus_ground.size()
	snap["containers_broken"] = containers_broken
	return snap


func _show_results() -> void:
	super._show_results()
	var left: int = results.left_on_ground + results.bonus_left
	_left_label.text = "Left on the ground: %d" % left
	if results.bonus_left > 0:
		_left_label.text += " (%d bonus)" % results.bonus_left
	_left_label.visible = left > 0
	_not_found_label.text = "Never picked up: %d" % results.not_found
	_not_found_label.visible = results.not_found > 0
	_bonus_label.text = "Bonus gold from chests: %d collected of %d" % [results.bonus_collected, results.bonus_generated]
	_bonus_label.visible = results.bonus_generated > 0
	_merchant_label.visible = results.merchant_met


## P006 prints its own line after the deposit instead of P005's line.
func _print_expedition() -> void:
	pass


func _result_lines() -> Array[Label]:
	return [_treasury_label, _bonus_label, _not_found_label, _merchant_label]


func _show_treasury() -> void:
	_treasury_label.visible = session != null
	_treasury_label.text = "Treasury: %d + %d = %d" % [treasury_before, results.secured, treasury_after]


func _update_hints() -> void:
	_abandon_hint.visible = not extracted
	_abandon_hint.text = ("Back" if _using_pad else "R") + " — Abandon expedition (carried gold is lost)"
	_attack_hint.visible = _sword.owned and not extracted
	_attack_hint.text = ("X (left button)" if _using_pad else "J / Space") + " — Swing sword"
	if can_meet_merchant():
		_prompt.visible = true
		_prompt.text = ("A (bottom button)" if _using_pad else "E") + " — Invite the merchant to your camp"


func _thief_text() -> String:
	if outcome != "" and outcome != "no gold":
		return outcome
	return "in progress" if encounter_used else "not triggered"


func _merchant_text() -> String:
	if results.merchant_met:
		return "met this run"
	if session != null and session.merchant_recruited:
		return "already at camp"
	return "not met"


func _sword_text() -> String:
	if session == null:
		return "n/a"
	if session.sword_owned:
		return "owned"
	return "affordable (%d)" % treasury_after if treasury_after >= session.sword_price else "not yet (%d/%d)" % [treasury_after, session.sword_price]


func _print_p006() -> void:
	print("P006 expedition | run %d | secured %d | treasury %d -> %d | deposited %s | standard collected %d/%d | bonus generated %d collected %d left %d | lost to thief %d | left on ground %d | not found %d | merchant %s | thief %s | sword %s | time %s" % [
		run_id, results.secured, treasury_before, treasury_after, "yes" if deposited else "no",
		results.standard_collected, level_total, results.bonus_generated, results.bonus_collected, results.bonus_left,
		results.lost_to_thief, results.left_on_ground, results.not_found,
		_merchant_text(), _thief_text(), _sword_text(), _format_time(results.time)])
