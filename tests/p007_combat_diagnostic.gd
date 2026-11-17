extends SceneTree
## P007 combat diagnostic: scripted play styles against the current tuning. REPORT ONLY.
## Prints what happened; it has no pass/fail balance expectations and is not a regression test.
## Scripted play is deterministic, so repeating a style gives the same result: one run per style
## is not independent evidence, and none of this measures feel, fairness, or enjoyment.
##
## Styles:
##   spam-in-place   walk up to the enemy, stop, then press attack as often as it is accepted
##   spam-advancing  keep walking into the enemy while pressing attack as often as accepted
##   deliberate      wait, dodge away from a committed strike, walk in and attack during recovery
##
## Run from the repository root (Godot 4.7.2):
##   <godot> --headless --path . --script res://tests/p007_combat_diagnostic.gd

const P007 := "res://game/prototypes/p007_combat_foundation.tscn"
const CombatSector := preload("res://game/prototypes/p007/combat_sector.gd")
const MOVES: Array[String] = ["move_left", "move_right", "move_up", "move_down"]
const MAX_TICKS: int = 60 * 30
const E_APPROACH := 1
const E_WINDUP := 2
const E_RECOVERY := 4

var _attack_down: bool = false
var _dodge_down: bool = false


func _initialize() -> void:
	_run()


func _run() -> void:
	for style: String in ["spam-in-place", "spam-advancing", "deliberate"]:
		await _play(style)
	quit(0)


func _load() -> void:
	_release_all()
	var old_id: int = current_scene.get_instance_id() if current_scene != null else 0
	if current_scene == null:
		change_scene_to_file(P007)
	else:
		reload_current_scene()
	for i in 30:
		await process_frame
		if current_scene != null and current_scene.get_instance_id() != old_id and current_scene.is_node_ready():
			break
	await physics_frame


func _release_all() -> void:
	for action: String in MOVES + ["attack", "dodge"]:
		Input.action_release(action)
	_attack_down = false
	_dodge_down = false


func _hold(v: Vector2) -> void:
	for action: String in MOVES:
		Input.action_release(action)
	if v.x > 0.0: Input.action_press("move_right", v.x)
	if v.x < 0.0: Input.action_press("move_left", -v.x)
	if v.y > 0.0: Input.action_press("move_down", v.y)
	if v.y < 0.0: Input.action_press("move_up", -v.y)


## Alternates press/release so each press is a fresh "just pressed".
func _pulse_attack(want: bool) -> void:
	if want and not _attack_down:
		Input.action_press("attack")
		_attack_down = true
	elif _attack_down:
		Input.action_release("attack")
		_attack_down = false


func _pulse_dodge(want: bool) -> void:
	if want and not _dodge_down:
		Input.action_press("dodge")
		_dodge_down = true
	elif _dodge_down:
		Input.action_release("dodge")
		_dodge_down = false


func _play(style: String) -> void:
	await _load()
	var root: Node = current_scene
	var k: Variant = root.get_node("King")
	var e: Variant = root.get_node("TrainingEnemy")
	var closed_in: bool = false
	var first_windup_tick: int = -1
	var first_recovery_tick: int = -1
	for tick in MAX_TICKS:
		if root.result != "":
			break
		if first_windup_tick < 0 and e.state == E_WINDUP:
			first_windup_tick = tick
		if first_recovery_tick < 0 and e.state == E_RECOVERY:
			first_recovery_tick = tick
		var to_enemy: Vector3 = e.global_position - k.global_position
		var flat_to: Vector2 = Vector2(to_enemy.x, to_enemy.z)
		var dist: float = flat_to.length()
		var toward: Vector2 = flat_to.normalized()
		match style:
			"spam-in-place":
				if not closed_in and dist > 1.3:
					_hold(toward)
				else:
					closed_in = true
					_hold(Vector2.ZERO)
					_pulse_attack(k.attack_phase == 0)
			"spam-advancing":
				_hold(toward)
				_pulse_attack(k.attack_phase == 0)
			"deliberate":
				var in_zone: bool = CombatSector.contains(e.global_position, e.strike_dir, e.strike_reach, e.strike_arc_degrees, k.global_position)
				if e.state == E_WINDUP and e.committed and in_zone and e.state_time >= e.windup - 0.1:
					_hold(-toward)
					_pulse_dodge(true)
					_pulse_attack(false)
				elif e.state == E_RECOVERY:
					_pulse_dodge(false)
					if dist > 1.2:
						_hold(toward)
						_pulse_attack(false)
					else:
						_hold(Vector2.ZERO)
						_pulse_attack(k.attack_phase == 0)
				else:
					_pulse_dodge(false)
					_pulse_attack(false)
					# Turn to face the enemy without walking into its range.
					_hold(toward * 0.5 if k.facing_dir.dot(Vector3(toward.x, 0, toward.y)) < 0.9 and dist > 1.6 else Vector2.ZERO)
		await physics_frame
	_release_all()
	var outcome: String = root.result if root.result != "" else "unfinished after %d s" % (MAX_TICKS / 60)
	print("INFO  %-15s | %s | %.2f s | damage taken %d | King health %d/%d | enemy health %d/%d | enemy attacks %d started, %d completed | first windup %.2f s, first recovery %s | swings %d | dodges %d (confirmed %d, cancels %d) | moved %s (%.1f m walked) | dodged %s" % [
		style, outcome, root.elapsed, root.hits_taken, k.health, k.max_health, e.health, e.max_health,
		e.attacks_started, e.attacks_completed, first_windup_tick / 60.0,
		"%.2f s" % (first_recovery_tick / 60.0) if first_recovery_tick >= 0 else "never",
		k.swings, k.dodges, e.dodges_confirmed, k.cancels,
		"yes" if root.walked > 0.05 else "no", root.walked, "yes" if k.dodges > 0 else "no"])
