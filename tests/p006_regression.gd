extends SceneTree
## P006 regression checks: session state, scene transitions, deposits, abandon, merchant, shop,
## sword, containers, and bonus-gold accounting. Mechanical only; never satisfaction, motivation,
## readability, or feel.
##
## Run from the repository root (Godot 4.7.2):
##   <godot> --headless --path . --script res://tests/p006_regression.gd
## Exit code 0 when every check passes, 1 otherwise.

const P006 := "res://game/prototypes/p006_meaningful_extraction_rewards.tscn"
const HUB_SCRIPT := "res://game/prototypes/p006/camp_hub.gd"
const EXPEDITION_SCRIPT := "res://game/prototypes/p006/expedition.gd"
const MOVES: Array[String] = ["move_left", "move_right", "move_up", "move_down"]
const CAMP := Vector3(0, 0, 11.5)
const DEPARTURE := Vector3(0, 0, 6)
## P005 routes, unchanged, walked inside the P006 expedition.
const ROUTE_WEST: Array[Vector3] = [
	Vector3(-1.6, 0, 9.2), Vector3(-0.6, 0, 8.0), Vector3(-4.5, 0, 3.0), Vector3(-8.5, 0, 0.5), Vector3(-12.5, 0, -1.5),
	Vector3(-13.75, 0, -5.0), Vector3(-13.75, 0, -8.0), Vector3(-13.0, 0, -9.0), Vector3(-10.5, 0, -11.5),
	Vector3(-7.6, 0, -11.0), Vector3(-7.6, 0, -12.8), Vector3(-6.0, 0, -13.0), Vector3(-4.4, 0, -12.8),
	Vector3(-4.4, 0, -11.0), Vector3(-4.4, 0, -9.0), Vector3(-6.0, 0, -9.0), Vector3(-13.75, 0, -8.0),
	Vector3(-13.75, 0, -4.0), Vector3(-12.5, 0, -1.5), Vector3(-8.5, 0, 0.5), Vector3(-4.5, 0, 3.0), CAMP]
const ROUTE_EAST: Array[Vector3] = [
	Vector3(1.6, 0, 9.2), Vector3(0.6, 0, 8.0), Vector3(3.5, 0, 1.5), Vector3(5.75, 0, -1.0), Vector3(5.75, 0, -7.6),
	Vector3(3.5, 0, -9.0), Vector3(2.0, 0, -11.0), Vector3(9.6, 0, -11.0), Vector3(11.4, 0, -11.0),
	Vector3(11.4, 0, -11.6), Vector3(9.6, 0, -11.6), Vector3(5.75, 0, -7.6), Vector3(5.75, 0, -1.0),
	Vector3(3.5, 0, 1.5), CAMP]
const ROUTE_TO_LURES: Array[Vector3] = [
	Vector3(1.6, 0, 9.2), Vector3(0.6, 0, 8.0), Vector3(3.5, 0, 1.5), Vector3(5.75, 0, -1.0), Vector3(5.75, 0, -7.6),
	Vector3(3.5, 0, -9.0), Vector3(2.0, 0, -11.0)]
const ENGAGE := Vector3(6.5, 0, -10.0)
const ROUTE_HOME_FROM_B: Array[Vector3] = [Vector3(5.75, 0, -7.6), Vector3(5.75, 0, -1.0), Vector3(3.5, 0, 1.5), CAMP]

var passes: int = 0
var fails: int = 0
var session: Node
## Physics frames on which the expedition invariant failed during scripted play.
var invariant_breaks: int = 0
var frames_checked: int = 0


func _initialize() -> void:
	create_timer(900.0).timeout.connect(func() -> void:
		print("FAIL  watchdog: test did not finish (script error or stuck scenario)")
		quit(1))
	_run()


func check(cond: bool, msg: String) -> void:
	if cond:
		passes += 1
		print("PASS  ", msg)
	else:
		fails += 1
		print("FAIL  ", msg)


func scene() -> Node:
	return session.current


func in_expedition() -> bool:
	return is_instance_valid(scene()) and scene().get_script().resource_path == EXPEDITION_SCRIPT


func in_hub() -> bool:
	return is_instance_valid(scene()) and scene().get_script().resource_path == HUB_SCRIPT


func step() -> void:
	await physics_frame
	if in_expedition() and scene().is_inside_tree() and not scene().extracted:
		frames_checked += 1
		if not scene().expedition_ok():
			invariant_breaks += 1


func wait(frames: int) -> void:
	for i in frames:
		await step()


func wait_until(cond: Callable, max_frames: int) -> bool:
	for i in max_frames:
		if cond.call():
			return true
		await step()
	return cond.call()


## A brand-new session: treasury 0, nothing recruited or owned.
func new_session() -> void:
	paused = false
	if current_scene == null:
		change_scene_to_file(P006)
	else:
		reload_current_scene()
	await process_frame
	await process_frame
	await physics_frame
	session = current_scene


## Waits for the session to show a different child than `old_id`.
func await_switch(old_id: int) -> bool:
	for i in 20:
		if is_instance_valid(scene()) and scene().get_instance_id() != old_id and scene().is_node_ready():
			break
		await process_frame
	await physics_frame
	return is_instance_valid(scene()) and scene().get_instance_id() != old_id


func player() -> CharacterBody3D:
	return scene().get_node("Player")


func thief() -> Node:
	return scene().get_node("Thief")


func flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func release_all() -> void:
	for a in MOVES:
		Input.action_release(a)


func press(v: Vector2) -> void:
	release_all()
	if v.x < 0.0: Input.action_press("move_left", -v.x)
	if v.x > 0.0: Input.action_press("move_right", v.x)
	if v.y < 0.0: Input.action_press("move_up", -v.y)
	if v.y > 0.0: Input.action_press("move_down", v.y)


func teleport(pos: Vector3) -> void:
	player().global_position = pos
	player().velocity = Vector3.ZERO


func walk_to(target: Vector3, max_frames: int = 360, tolerance: float = 0.15) -> bool:
	for i in max_frames:
		var d := Vector2(target.x - player().global_position.x, target.z - player().global_position.z)
		if d.length() <= tolerance:
			release_all()
			return true
		press(d.normalized())
		await step()
	release_all()
	return flat(player().global_position, target) <= tolerance


## Returns the index of the first unreached waypoint, or -1 if all were reached.
func walk_route(route: Array[Vector3]) -> int:
	for i in route.size():
		if not await walk_to(route[i]):
			return i
	return -1


func chase(max_frames: int = 300) -> void:
	for i in max_frames:
		if scene().dropped > 0 or thief().state == thief().State.GONE:
			break
		var d := Vector2(thief().global_position.x - player().global_position.x, thief().global_position.z - player().global_position.z)
		press(d.normalized())
		await step()
	release_all()


func tap_key(code: Key) -> void:
	var down := InputEventKey.new()
	# Project actions bind physical keys; built-in ui_* actions (Enter for ui_accept) bind keycodes.
	down.physical_keycode = code
	down.keycode = code
	down.pressed = true
	Input.parse_input_event(down)
	await process_frame
	var up: InputEventKey = down.duplicate()
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame
	await physics_frame


func top_speed(v: Vector2) -> float:
	press(v)
	var best := 0.0
	for i in 40:
		await physics_frame
		best = maxf(best, Vector2(player().velocity.x, player().velocity.z).length())
	release_all()
	return best


## From the hub: walk to the road and press E. Returns whether a fresh expedition started.
func depart() -> bool:
	if not in_hub():
		return false
	await walk_to(DEPARTURE)
	var old: int = scene().get_instance_id()
	await tap_key(KEY_E)
	return await await_switch(old) and in_expedition()


func extract_at_camp() -> bool:
	await walk_to(CAMP)
	await tap_key(KEY_E)
	return scene().extracted


## From the results panel: wait out the focus delay, then confirm with Enter.
func continue_to_camp() -> bool:
	await focus_delay()
	var old: int = scene().get_instance_id()
	await tap_key(KEY_ENTER)
	return await await_switch(old) and in_hub()


## Headless frames run faster than real time, so wait out the results focus delay on a real timer.
func focus_delay() -> void:
	await create_timer(scene().results_focus_delay + 0.15).timeout
	await process_frame


func results_sum_ok() -> bool:
	var r: Dictionary = scene().results
	return r.secured + r.lost_to_thief + r.left_on_ground + r.not_found + r.get("bonus_left", 0) == 25 + r.get("bonus_generated", 0)


func _run() -> void:
	await new_session()

	print("--- Session and initial hub")
	check(ProjectSettings.get_setting("application/run/main_scene") == P006, "default main scene is P006")
	check(in_hub(), "session starts in the camp hub")
	check(session.treasury == 0 and not session.merchant_recruited and not session.sword_owned and session.run_id == 0,
		"treasury 0, merchant not recruited, sword not owned")
	check(not scene().get_node("Stall").visible and scene().hoard_stage() == 0, "no stall and an empty hoard")
	check((scene().get_node("HUD/TreasuryLabel") as Label).text == "Treasury: 0", "HUD shows the exact treasury balance")
	check(not scene().near_departure() and not scene().get_node("HUD/Prompt").visible, "King starts away from the road with no prompt")
	var hub_id: int = scene().get_instance_id()
	await tap_key(KEY_E)
	await wait(3)
	check(in_hub() and scene().get_instance_id() == hub_id, "E away from the road does not depart")

	print("--- Departure and a zero-gold extraction")
	check(await depart(), "E at the road starts an expedition")
	check(session.run_id == 1 and scene().run_id == 1 and scene().gold_total == 0 and scene().get_node("Gold").get_child_count() == 25
		and scene().level_total == 25 and not scene().extracted, "fresh run: 0 carried, 25 standard pickups")
	check(scene().get_node("HUD/AbandonHint").visible and (scene().get_node("HUD/AbandonHint") as Label).text == "R — Abandon expedition (carried gold is lost)",
		"abandon hint is shown")
	check(flat(player().global_position, CAMP) < 0.1 and scene().in_camp(), "King starts at the expedition camp")
	await tap_key(KEY_E)
	var r: Dictionary = scene().results
	check(scene().extracted and r.secured == 0 and session.treasury == 0 and session.deposit_count == 1 and scene().deposited,
		"0-gold extraction deposits 0 once")
	check(scene().get_node("Results").visible and paused and (scene().get_node("Results/Panel/Box/Treasury") as Label).text == "Treasury: 0 + 0 = 0",
		"results show treasury before + deposit = after")
	check(not scene().get_node("HUD/AbandonHint").visible, "abandon hint hidden after extraction")
	check(results_sum_ok(), "extraction totals add up to 25")
	for i in 3:
		await tap_key(KEY_E)
	check(not scene().try_extract() and session.deposit_count == 1, "repeated E and try_extract do not deposit again")
	check(not session.complete_expedition(1, 5, false) and session.treasury == 0, "session refuses a second deposit for the same run")
	var exp_id: int = scene().get_instance_id()
	await tap_key(KEY_R)
	await wait(3)
	check(in_expedition() and scene().get_instance_id() == exp_id and scene().get_node("Results").visible and session.deposit_count == 1,
		"R on the results panel does not abandon or leave")
	check(scene().get_node("Results/Panel/Box/NewExpedition").shortcut == null and (scene().get_node("Results/Panel/Box/NewExpedition") as Button).text == "Continue to Camp",
		"results button is Continue to Camp with no R shortcut")
	check(await continue_to_camp(), "Enter on the results panel returns to camp")
	check(not paused and session.treasury == 0 and session.run_id == 1, "camp is unpaused; no new expedition started")

	print("--- Partial haul, then a second run that adds to it")
	check(await depart(), "second departure")
	check(session.run_id == 2 and scene().gold_total == 0 and scene().get_node("Gold").get_child_count() == 25 and scene().treasury_before == 0,
		"second run starts fresh")
	check(await walk_route(ROUTE_WEST) == -1, "P005 west route is walkable in the P006 expedition")
	var carried: int = scene().gold_total
	check(carried > 0 and carried < 25, "partial haul collected (%d)" % carried)
	check(is_equal_approx(await top_speed(Vector2.RIGHT), player().move_speed), "carrying %d gold does not slow the King" % carried)
	await walk_to(CAMP)
	check(await extract_at_camp(), "extracted with a partial haul")
	check(scene().results.secured == carried and session.treasury == carried and scene().treasury_after == carried, "deposit equals carried gold (%d)" % carried)
	check((scene().get_node("Results/Panel/Box/Treasury") as Label).text == "Treasury: 0 + %d = %d" % [carried, carried], "results treasury line matches the session")
	# Double confirmation in one frame must switch scenes only once.
	await focus_delay()
	var button: Button = scene().get_node("Results/Panel/Box/NewExpedition")
	var before_switch: int = scene().get_instance_id()
	button.pressed.emit()
	button.pressed.emit()
	check(await await_switch(before_switch) and in_hub(), "double Continue returns to camp")
	var hub_after: int = scene().get_instance_id()
	await wait(5)
	check(scene().get_instance_id() == hub_after and session.deposit_count == 2, "only one transition and no extra deposit")
	check((scene().get_node("HUD/TreasuryLabel") as Label).text == "Treasury: %d" % carried and scene().get_node("HUD/Notice").visible,
		"hub shows the new balance and an arrival notice")
	var treasury_two: int = session.treasury

	check(await depart(), "third departure")
	check(await walk_route(ROUTE_EAST) == -1, "P005 east route is walkable in the P006 expedition")
	var third: int = scene().gold_total
	check(await extract_at_camp(), "extracted after the east route")
	check(session.treasury == treasury_two + third and results_sum_ok(), "treasury accumulates across runs (%d + %d)" % [treasury_two, third])
	check(await continue_to_camp(), "back to camp")

	print("--- Abandon")
	var before_abandon: int = session.treasury
	check(await depart(), "departure before abandoning")
	await walk_to(Vector3(-1.6, 0, 9.2))
	check(scene().gold_total > 0, "carrying gold before abandoning")
	var old: int = scene().get_instance_id()
	await tap_key(KEY_R)
	check(await await_switch(old) and in_hub(), "R mid-expedition returns to camp")
	check(session.treasury == before_abandon and session.deposit_count == 3, "abandon deposits nothing; treasury kept")
	check((scene().get_node("HUD/Notice") as Label).text == session.ABANDON_NOTICE and scene().get_node("HUD/Notice").visible,
		"camp says nothing was secured")
	check(not session.complete_expedition(session.run_id, 7, false), "an abandoned run cannot deposit later")

	print("--- Expedition invariant")
	check(invariant_breaks == 0 and frames_checked > 500,
		"P006 expedition invariant held on every checked frame (%d frames, %d breaks)" % [frames_checked, invariant_breaks])

	print("--- Scenes load")
	for path in ["res://game/prototypes/p001_movement_camera.tscn", "res://game/prototypes/p002_gold_collection.tscn",
			"res://game/prototypes/p003_gold_power_burden.tscn", "res://game/prototypes/p004_gold_spill_theft.tscn",
			"res://game/prototypes/p005_mini_expedition_extraction.tscn", P006,
			"res://game/prototypes/p006/camp_hub.tscn", "res://game/prototypes/p006/expedition.tscn"]:
		var packed: PackedScene = load(path)
		var inst: Node = packed.instantiate() if packed != null else null
		check(inst != null, "%s instantiates" % path.get_file())
		if inst != null:
			inst.free()

	print("=== %d passed, %d failed (%d checks)" % [passes, fails, passes + fails])
	quit(1 if fails > 0 else 0)
