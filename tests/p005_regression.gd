extends SceneTree
## P005 regression checks: layout reachability, gold accounting, extraction, and replay mechanics
## only, never enjoyment, tension, or pacing.
##
## Run from the repository root (Godot 4.7.2):
##   <godot> --headless --path . --script res://tests/p005_regression.gd
## Exit code 0 when every check passes, 1 otherwise.

const P005 := "res://game/prototypes/p005_mini_expedition_extraction.tscn"
const MOVES: Array[String] = ["move_left", "move_right", "move_up", "move_down"]
const CAMP := Vector3(0, 0, 11.5)
const AREA_TOTALS: Dictionary = {"Camp": 4, "TrailW": 3, "TrailE": 2, "A": 6, "B": 10}
## Camp -> west gap -> every Branch A coin -> back to camp. Bends avoid LowBlockA and the north pillar.
const ROUTE_WEST: Array[Vector3] = [
	Vector3(-1.6, 0, 9.2), Vector3(-0.6, 0, 8.0), Vector3(-4.5, 0, 3.0), Vector3(-8.5, 0, 0.5), Vector3(-12.5, 0, -1.5),
	Vector3(-13.75, 0, -5.0), Vector3(-13.75, 0, -8.0), Vector3(-13.0, 0, -9.0), Vector3(-10.5, 0, -11.5),
	Vector3(-7.6, 0, -11.0), Vector3(-7.6, 0, -12.8), Vector3(-6.0, 0, -13.0), Vector3(-4.4, 0, -12.8),
	Vector3(-4.4, 0, -11.0), Vector3(-4.4, 0, -9.0), Vector3(-6.0, 0, -9.0), Vector3(-13.75, 0, -8.0),
	Vector3(-13.75, 0, -4.0), Vector3(-12.5, 0, -1.5), Vector3(-8.5, 0, 0.5), Vector3(-4.5, 0, 3.0), CAMP]
## Camp -> central passage -> every Branch B coin -> back to camp.
const ROUTE_EAST: Array[Vector3] = [
	Vector3(1.6, 0, 9.2), Vector3(0.6, 0, 8.0), Vector3(3.5, 0, 1.5), Vector3(5.75, 0, -1.0), Vector3(5.75, 0, -7.6),
	Vector3(3.5, 0, -9.0), Vector3(2.0, 0, -11.0), Vector3(9.6, 0, -11.0), Vector3(11.4, 0, -11.0),
	Vector3(11.4, 0, -11.6), Vector3(9.6, 0, -11.6), Vector3(5.75, 0, -7.6), Vector3(5.75, 0, -1.0),
	Vector3(3.5, 0, 1.5), CAMP]
## Camp -> Branch B lures, stopping just before the thief's trigger radius.
const ROUTE_TO_LURES: Array[Vector3] = [
	Vector3(1.6, 0, 9.2), Vector3(0.6, 0, 8.0), Vector3(3.5, 0, 1.5), Vector3(5.75, 0, -1.0), Vector3(5.75, 0, -7.6),
	Vector3(3.5, 0, -9.0), Vector3(2.0, 0, -11.0)]
## Inside the trigger radius, between the lures and the cluster.
const ENGAGE := Vector3(6.5, 0, -10.0)
const ROUTE_HOME_FROM_B: Array[Vector3] = [Vector3(5.75, 0, -7.6), Vector3(5.75, 0, -1.0), Vector3(3.5, 0, 1.5), CAMP]

var passes: int = 0
var fails: int = 0
var scene: Node
## Physics frames on which the expedition-wide invariant failed during scripted play.
var invariant_breaks: int = 0
var frames_checked: int = 0


func _initialize() -> void:
	# A script error inside the test coroutine stops it without quitting; fail instead of hanging.
	create_timer(540.0).timeout.connect(func() -> void:
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


## One physics frame, then the invariant check while an expedition is running.
func step() -> void:
	await physics_frame
	if is_instance_valid(scene) and scene.is_inside_tree() and not scene.extracted:
		frames_checked += 1
		if not scene.expedition_ok():
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


## Test-side reload for scenarios that skip the results panel; a paused tree survives reloads.
func load_fresh() -> void:
	paused = false
	if current_scene == null:
		change_scene_to_file(P005)
	else:
		reload_current_scene()
	await process_frame
	await process_frame
	await physics_frame
	scene = current_scene


## Waits for a reload started by the scene itself (New Expedition or R).
## The old scene may already be freed by the time this runs, so it is compared by instance id.
func await_reload(old_id: int) -> bool:
	for i in 20:
		if current_scene != null and current_scene.get_instance_id() != old_id and current_scene.is_node_ready():
			break
		await process_frame
	await physics_frame
	scene = current_scene
	return scene.get_instance_id() != old_id


## Prints the fields that differ from the fresh state, so a failed comparison says why.
func same_as(fresh: Dictionary) -> bool:
	var now: Dictionary = initial_state()
	for k in fresh:
		if now[k] != fresh[k]:
			print("      differs: %s = %s (fresh %s)" % [k, now[k], fresh[k]])
	return now == fresh


func player():
	return scene.get_node("Player")


func thief():
	return scene.get_node("Thief")


func flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func release_all() -> void:
	for a in MOVES:
		Input.action_release(a)


func press(v: Vector2) -> void:
	release_all()
	if v.x > 0.0: Input.action_press("move_right", v.x)
	if v.x < 0.0: Input.action_press("move_left", -v.x)
	if v.y > 0.0: Input.action_press("move_down", v.y)
	if v.y < 0.0: Input.action_press("move_up", -v.y)


func teleport(pos: Vector3) -> void:
	player().global_position = pos
	player().velocity = Vector3.ZERO


func drive(v: Vector2, frames: int) -> void:
	press(v)
	await wait(frames)
	release_all()


## Walks toward a point each frame until within `tolerance`. Returns whether it arrived.
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


## Walks a waypoint list; returns the index of the first unreached waypoint, or -1 if all were reached.
func walk_route(route: Array[Vector3]) -> int:
	for i in route.size():
		if not await walk_to(route[i]):
			return i
	return -1


## Chases the thief each frame until it is intercepted, escapes, or time runs out.
func chase(max_frames: int = 300) -> void:
	for i in max_frames:
		if scene.dropped > 0 or thief().state == thief().State.GONE:
			break
		var d := Vector2(thief().global_position.x - player().global_position.x, thief().global_position.z - player().global_position.z)
		press(d.normalized())
		await step()
	release_all()


func tap_key(code: Key) -> void:
	var down := InputEventKey.new()
	down.physical_keycode = code
	down.pressed = true
	Input.parse_input_event(down)
	await process_frame
	var up: InputEventKey = down.duplicate()
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame
	await physics_frame


func pouch_ok(gold: int) -> bool:
	var pouch: Node = scene.get_node("Player/Pouch")
	var tex: Texture2D = pouch.low_texture
	if gold >= pouch.overflowing_at: tex = pouch.overflowing_texture
	elif gold >= pouch.partial_at: tex = pouch.partial_texture
	return pouch.texture == tex


func hud_ok() -> bool:
	return (scene.get_node("HUD/GoldLabel") as Label).text == "Gold: %d" % scene.gold_total and pouch_ok(scene.gold_total)


func top_speed(v: Vector2) -> float:
	teleport(Vector3(-13, 0, 13.5))
	press(v)
	var best := 0.0
	for i in 40:
		await physics_frame
		best = maxf(best, Vector2(player().velocity.x, player().velocity.z).length())
	release_all()
	return best


## Level pickups not yet collected, counted directly from the pickups.
func uncollected_pickups() -> int:
	var n := 0
	for c in scene.get_node("Gold").get_children():
		if not c._collected:
			n += c.value
	return n


func results_sum_ok() -> bool:
	var r: Dictionary = scene.results
	return r.secured + r.lost_to_thief + r.left_on_ground + r.not_found == 25 and r.not_found == uncollected_pickups()


## Everything a fresh expedition must restore, for comparing runs.
func initial_state() -> Dictionary:
	var t = thief()
	return {"gold": scene.gold_total, "pickups": scene.get_node("Gold").get_child_count(), "uncollected": uncollected_pickups(),
		"level_collected": scene.level_collected, "spilled": scene.spilled, "stolen": scene.stolen, "lost": scene.lost,
		"thief_held": scene.thief_held, "ground": scene.ground.size(), "spill_nodes": scene.get_node("SpillCoins").get_child_count(),
		"encounter_used": scene.encounter_used, "thief_state": t.state, "thief_visible": t.visible,
		"thief_pos": t.global_position.snapped(Vector3.ONE * 0.001), "player_pos": Vector2(player().global_position.x, player().global_position.z).snapped(Vector2.ONE * 0.001),
		"extracted": scene.extracted, "extractions": scene.extraction_count, "results": scene.results,
		"results_visible": scene.get_node("Results").visible, "prompt": scene.get_node("HUD/ExtractPrompt").visible,
		"paused": paused, "hud": (scene.get_node("HUD/GoldLabel") as Label).text}


## Walks into the thief's trigger radius carrying gold and waits for contact.
func engage() -> bool:
	await walk_route(ROUTE_TO_LURES)
	await walk_to(ENGAGE)
	return await wait_until(func() -> bool: return thief().state == thief().State.PAUSE, 400)


func extract_at_camp() -> bool:
	await walk_to(CAMP)
	await tap_key(KEY_E)
	return scene.extracted


func _run() -> void:
	await load_fresh()
	var p = player()
	var t = thief()

	print("--- Scene and initial state")
	check(ProjectSettings.get_setting("application/run/main_scene") == P005, "main scene is P005")
	var coins: Array = scene.get_node("Gold").get_children()
	var all_one := true
	var by_area: Dictionary = {}
	for c in coins:
		all_one = all_one and c.value == 1
		var area: String = scene._area_of(c.name)
		by_area[area] = by_area.get(area, 0) + 1
	check(coins.size() == 25 and all_one and scene.level_total == 25, "25 one-value level pickups")
	check(by_area == AREA_TOTALS, "gold by area: camp 4, west trail 3, east trail 2, branch A 6, branch B 10 (%s)" % by_area)
	check(scene.gold_total == 0 and scene.haul_start == 0 and scene.expedition_ok() and hud_ok(), "King starts with 0 gold; ledger and HUD in sync")
	check(flat(p.global_position, CAMP) < 0.01 and scene.in_camp(), "King starts at camp")
	check(t.state == t.State.IDLE and t.visible and flat(t.global_position, scene.get_node("Burrow").global_position) < 0.01, "thief idle at its burrow")
	check(not scene.get_node("Results").visible and not paused and not scene.extracted and scene.extraction_count == 0 and scene.results.is_empty(), "results hidden; not paused; not extracted")
	check(not scene.get_node("HUD/EncounterLabel").visible and scene.get_node("HUD/GoldLabel").visible, "P004 test status line hidden; gold counter shown")
	var prompt: Label = scene.get_node("HUD/ExtractPrompt")
	check(prompt.visible and prompt.text == "E — Secure haul and end expedition", "extraction prompt shown in camp: \"%s\"" % prompt.text)
	var disc: CylinderMesh = scene.get_node("Camp/Disc").mesh
	check(scene.extraction_radius == 2.5 and disc.top_radius == 2.5 and flat(scene.get_node("Camp").global_position, CAMP) < 0.01, "camp at (0, 11.5); disc radius equals extraction radius 2.5")
	check(scene.trigger_radius == 9.0 and scene.spill_cap == 3 and scene.steal_cap == 1 and t.warn_time == 1.0 and t.give_up_time == 8.0
		and t.pause_time == 0.5 and t.approach_speed == 3.0 and t.grab_speed == 3.5 and t.flee_speed == 3.5 and t.contact_radius == 0.8
		and t.claim_radius == 0.4 and t.intercept_radius == 1.0, "P004 thief tuning unchanged")
	check(t.zone_min == Vector2(0, -14.6) and t.zone_max == Vector2(14.6, -7.4) and scene.coin_min == Vector2(0.4, -14.3) and scene.coin_max == Vector2(14.3, -7.7),
		"thief zone and spill bounds fitted to the north-east chamber")
	var split_ok := true
	for c in coins:
		var n: String = c.name
		if n.begins_with("A") and c.global_position.x > -1.5 - 0.45: split_ok = false
		if n.begins_with("B") and c.global_position.x < -0.5 + 0.45: split_ok = false
		if n.begins_with("BLure") and flat(c.global_position, t.home_position()) <= scene.trigger_radius: split_ok = false
		if n.begins_with("B") and not n.begins_with("BLure") and flat(c.global_position, t.home_position()) > scene.trigger_radius: split_ok = false
	check(split_ok and t.zone_min.x > -0.5, "branch A coins west of NorthSplit, branch B coins east; lures outside the trigger, cluster inside; thief zone excludes branch A")
	var interact_events := InputMap.action_get_events("interact")
	var has_e := false
	var has_pad := false
	for e in interact_events:
		if e is InputEventKey and e.physical_keycode == KEY_E: has_e = true
		if e is InputEventJoypadButton and e.button_index == JOY_BUTTON_A: has_pad = true
	check(interact_events.size() == 2 and has_e and has_pad, "interact action: E and gamepad button 0")
	check(p.move_speed == 5.0 and p.acceleration == 80.0 and p.deceleration == 120.0, "P001 movement values unchanged (5.0 / 80 / 120)")
	var fresh: Dictionary = initial_state()

	print("--- P004 presets inactive")
	for key in [KEY_1, KEY_2, KEY_3]:
		await tap_key(key)
	check(scene.gold_total == 0 and scene.haul_start == 0 and flat(p.global_position, CAMP) < 0.01 and scene.expedition_ok(), "keys 1 / 2 / 3 do not change gold or move the King")

	print("--- Geometry")
	teleport(Vector3(-11.0, 0, -1.0))
	await drive(Vector2(0, -1), 60)
	check(p.global_position.z > -2.6, "shortened DividerWest still blocks east of the west gap")
	teleport(Vector3(-13.75, 0, -1.0))
	await drive(Vector2(0, -1), 90)
	check(p.global_position.z < -8.0, "west gap passable into the north-west chamber")
	teleport(Vector3(2.0, 0, -11.0))
	await drive(Vector2(-1, 0), 60)
	check(p.global_position.x > -0.1, "NorthSplit separates the two chambers (east side)")
	teleport(Vector3(-4.0, 0, -11.0))
	await drive(Vector2(1, 0), 60)
	check(p.global_position.x < -1.9, "NorthSplit separates the two chambers (west side)")
	teleport(Vector3(5.75, 0, -1.5))
	await drive(Vector2(0, -1), 120)
	check(p.global_position.z < -8.0, "central passage passable into the north-east chamber")
	await load_fresh()
	p = player()
	t = thief()
	check(same_as(fresh), "reload after geometry probes restores the initial state")

	print("--- Full expedition: both branches, thief held still")
	t.set_physics_process(false)
	var west_fail := await walk_route(ROUTE_WEST)
	check(west_fail == -1, "branch A route from camp and back is walkable (stuck at waypoint %d)" % west_fail)
	var r_mid: Dictionary = scene._snapshot()
	check(r_mid.by_area["Camp"] == 2 and r_mid.by_area["TrailW"] == 3 and r_mid.by_area["A"] == 6 and scene.gold_total == 11 and hud_ok(),
		"west route collects 2 camp, 3 west trail, 6 branch A coins (gold %d)" % scene.gold_total)
	check(scene.in_camp() and not scene.extracted, "back in camp after branch A; not extracted")
	var east_fail := await walk_route(ROUTE_EAST)
	check(east_fail == -1, "branch B route from camp and back is walkable (stuck at waypoint %d)" % east_fail)
	check(scene.gold_total == 25 and uncollected_pickups() == 0 and scene.level_collected == 25 and hud_ok(), "all 25 coins reachable and collected; HUD and pouch at 25")
	check(scene.in_camp() and not scene.extracted, "back in camp after branch B; not extracted")
	await wait(300)
	check(not scene.extracted and scene.extraction_count == 0 and not paused and scene.get_node("HUD/ExtractPrompt").visible, "5 s idle in camp with 25 gold: no automatic extraction; prompt shown")
	var straight := await top_speed(Vector2(1, 0))
	var diagonal := await top_speed(Vector2(1, -1).normalized())
	check(absf(straight - 5.0) < 0.01 and absf(diagonal - 5.0) < 0.01, "carrying 25: top speed %.3f, diagonal %.3f" % [straight, diagonal])
	teleport(Vector3(-13, 0, 13.5))
	press(Vector2(1, 0))
	await physics_frame
	var first_step: float = p.velocity.length()
	await wait(10)
	release_all()
	var v_top: float = p.velocity.length()
	await physics_frame
	check(absf(first_step - 80.0 / 60.0) < 0.01 and absf(v_top - p.velocity.length() - 2.0) < 0.01, "acceleration and deceleration steps unchanged with 25 gold")
	await wait(4)
	await process_frame
	var pitch := deg_to_rad(52.0)
	check((scene.get_node("Camera") as Node3D).global_position.distance_to(p.global_position + Vector3(0, sin(pitch), cos(pitch)) * 12.0) < 0.01, "camera follow offset unchanged")

	print("--- Extraction")
	teleport(CAMP + Vector3(scene.extraction_radius + 0.3, 0, 0))
	await wait(2)
	check(not scene.get_node("HUD/ExtractPrompt").visible, "prompt hidden just outside camp")
	await tap_key(KEY_E)
	check(not scene.extracted and not paused, "E just outside camp does not extract")
	teleport(CAMP + Vector3(scene.extraction_radius - 0.3, 0, 0))
	await wait(2)
	check(scene.get_node("HUD/ExtractPrompt").visible, "prompt shown just inside camp")
	var time_before: float = scene.elapsed
	await tap_key(KEY_E)
	check(scene.extracted and scene.extraction_count == 1 and paused, "E inside camp extracts once and pauses the expedition")
	var r: Dictionary = scene.results
	check(r.secured == 25 and r.lost_to_thief == 0 and r.left_on_ground == 0 and r.not_found == 0 and results_sum_ok(), "full haul: secured 25, lost 0, left 0, not found 0")
	check(r.time >= time_before and r.time < time_before + 0.1 and r.time > 10.0, "expedition time recorded (%.1f s)" % r.time)
	check(scene.get_node("Results").visible and not scene.get_node("HUD/ExtractPrompt").visible, "results shown; prompt hidden")
	check(scene.get_node("Results/Panel/Box/Secured").text == "Gold secured: 25" and not scene.get_node("Results/Panel/Box/Lost").visible
		and not scene.get_node("Results/Panel/Box/Left").visible and scene.get_node("Results/Panel/Box/Time").text == "Time: %s" % scene._format_time(r.time),
		"results text: secured 25; lost and left lines hidden when 0; time m:ss")
	check(scene.get_node("Results/Panel/Box/Note").text == "Each expedition starts fresh — nothing is carried over.", "results note says nothing is carried over")
	var frozen: Dictionary = r.duplicate(true)
	var pos_frozen: Vector3 = p.global_position
	for i in 5:
		await tap_key(KEY_E)
	check(not scene.try_extract(), "a direct second extraction call is refused")
	await wait(60)
	check(scene.extraction_count == 1 and scene.results == frozen and scene.gold_total == 25, "repeated E and 1 s of frames: one extraction, results unchanged")
	press(Vector2(1, 0))
	await wait(30)
	release_all()
	check(p.global_position == pos_frozen, "the King cannot move after extraction")
	check(scene.get_node("Results/Panel/Box/NewExpedition").has_focus(), "New Expedition takes focus after the delay")

	print("--- New Expedition button")
	var old: int = scene.get_instance_id()
	scene.get_node("Results/Panel/Box/NewExpedition").pressed.emit()
	check(await await_reload(old), "New Expedition reloads the scene")
	p = player()
	t = thief()
	check(same_as(fresh), "fresh expedition: gold 0, 25 pickups, idle thief, King at camp, unpaused, results hidden")

	print("--- Zero-gold extraction and R from results")
	await tap_key(KEY_E)
	r = scene.results
	check(scene.extracted and r.secured == 0 and r.lost_to_thief == 0 and r.left_on_ground == 0 and r.not_found == 25 and results_sum_ok(), "extracting at once: secured 0, not found 25")
	old = scene.get_instance_id()
	await tap_key(KEY_R)
	check(await await_reload(old), "R on the results panel starts a new expedition")
	p = player()
	t = thief()
	check(same_as(fresh), "fresh expedition after R matches the initial state")

	print("--- R during an expedition")
	await walk_route([Vector3(-1.6, 0, 9.2), Vector3(1.6, 0, 9.2)])
	check(scene.gold_total > 0, "collected camp gold (%d)" % scene.gold_total)
	old = scene.get_instance_id()
	await tap_key(KEY_R)
	check(await await_reload(old), "R mid-expedition reloads")
	p = player()
	t = thief()
	check(same_as(fresh), "abandoned run: nothing secured or carried over")

	print("--- Camp gold only")
	await walk_route([Vector3(-1.6, 0, 9.2), Vector3(-0.6, 0, 8.0), Vector3(0.6, 0, 8.0), Vector3(1.6, 0, 9.2)])
	check(await extract_at_camp(), "extracted after the camp coins")
	r = scene.results
	check(r.secured == 4 and scene.gold_total == 4 and r.by_area["Camp"] == 4 and r.not_found == 21 and results_sum_ok(), "secured exactly the 4 carried camp coins")
	old = scene.get_instance_id()
	await tap_key(KEY_R)
	await await_reload(old)

	print("--- Branch A then extract")
	await load_fresh()
	p = player()
	t = thief()
	await walk_route(ROUTE_WEST)
	check(await extract_at_camp(), "extracted after branch A")
	r = scene.results
	check(r.by_area["A"] == 6 and r.secured == r.by_area["Camp"] + r.by_area["TrailW"] + r.by_area["A"] and r.secured == 11 and results_sum_ok(),
		"branch A reward reflected: secured %d, not found %d" % [r.secured, r.not_found])

	print("--- Branch B: avoid the thief")
	await load_fresh()
	p = player()
	t = thief()
	await walk_route(ROUTE_TO_LURES)
	var carried: int = scene.gold_total
	check(t.state == t.State.IDLE and carried > 0, "lures collected outside the trigger; thief still idle (gold %d)" % carried)
	await walk_to(ENGAGE)
	check(await wait_until(func() -> bool: return t.state == t.State.ALERT, 10), "entering the trigger radius with gold: thief warns")
	await walk_to(Vector3(5.75, 0, -7.6))
	await walk_to(Vector3(5.75, 0, -1.0))
	check(await wait_until(func() -> bool: return t.state == t.State.GONE, 900), "retreating through the passage: thief gives up and returns")
	check(scene.outcome == "avoided" and scene.spilled == 0 and scene.gold_total == carried, "outcome avoided; gold kept")
	check(t.global_position.z <= t.zone_max.y + 0.001, "thief never left its chamber")
	await walk_route([Vector3(3.5, 0, 1.5), CAMP])
	check(await extract_at_camp(), "extracted after avoiding the thief")
	r = scene.results
	check(r.secured == scene.gold_total and r.lost_to_thief == 0 and r.left_on_ground == 0 and results_sum_ok(), "secured %d; nothing lost" % r.secured)

	print("--- Branch B: thief escapes with gold")
	await load_fresh()
	p = player()
	t = thief()
	var contact := await engage()
	var at_contact: int = scene.gold_total + scene.spilled
	check(contact and scene.spilled == 3 and scene.ground.size() == 3, "standing still: contact spills 3 of %d gold" % at_contact)
	await wait_until(func() -> bool: return scene.thief_held == 1, 200)
	check(await wait_until(func() -> bool: return t.state == t.State.GONE, 600) and scene.lost == 1 and scene.outcome == "escaped with gold", "thief escapes with 1 gold")
	await walk_route(ROUTE_HOME_FROM_B)
	check(await extract_at_camp(), "extracted after the theft")
	r = scene.results
	check(r.secured == at_contact - 3 and r.lost_to_thief == 1 and r.left_on_ground == 2 and results_sum_ok(), "secured %d, lost to thief 1, left on ground 2" % r.secured)
	check(scene.get_node("Results/Panel/Box/Lost").visible and scene.get_node("Results/Panel/Box/Lost").text == "Lost to the thief: 1"
		and scene.get_node("Results/Panel/Box/Left").visible and scene.get_node("Results/Panel/Box/Left").text == "Left on the ground: 2", "results show the loss and the coins left behind")

	print("--- Branch B: interception and recovery")
	await load_fresh()
	p = player()
	t = thief()
	await engage()
	await wait_until(func() -> bool: return scene.thief_held == 1, 200)
	await chase()
	check(scene.dropped == 1 and scene.thief_held == 0, "prompt chase intercepts the thief")
	await wait(25)
	while not scene.ground.is_empty():
		var before: int = scene.ground.size()
		await walk_to(scene.ground[0].global_position, 240, 0.1)
		await wait(3)
		if scene.ground.size() == before:
			break
	await wait_until(func() -> bool: return t.state == t.State.GONE, 600)
	check(scene.ground.is_empty() and scene.recovered == 3 and scene.lost == 0 and scene.outcome == "intercepted", "all 3 spilled coins recovered, including the dropped one")
	var with_recovered: int = scene.gold_total
	await walk_route(ROUTE_HOME_FROM_B)
	check(await extract_at_camp(), "extracted after recovery")
	r = scene.results
	check(r.secured == with_recovered and r.lost_to_thief == 0 and r.left_on_ground == 0 and results_sum_ok(), "recovered gold counts toward the secured %d" % r.secured)

	print("--- Extraction while the thief still holds gold")
	await load_fresh()
	p = player()
	t = thief()
	await engage()
	await wait_until(func() -> bool: return scene.thief_held == 1, 200)
	check(t.state == t.State.FLEE and scene.lost == 0, "thief fleeing with 1 gold")
	teleport(CAMP)
	var carried_now: int = scene.gold_total
	scene.try_extract()
	check(not scene.try_extract() and scene.extraction_count == 1, "two extraction calls in the same frame: the second is refused")
	r = scene.results
	check(r.secured == carried_now and r.lost_to_thief == 1 and r.left_on_ground == 2 and results_sum_ok(), "thief-held coin forfeited: secured %d, lost 1, left 2" % r.secured)
	var thief_pos: Vector3 = t.global_position
	var spilled_coin = scene.ground[0]
	spilled_coin._on_body_entered(p)
	check(not scene._try_recover(spilled_coin) and not spilled_coin.popped and scene.gold_total == carried_now, "after extraction a spilled coin cannot be recovered or pop")
	await wait(60)
	check(t.global_position == thief_pos and t.state == t.State.FLEE and scene.lost == 0 and scene.results == r, "thief frozen; results unchanged")
	await tap_key(KEY_R)

	print("--- Expedition-wide invariant")
	check(invariant_breaks == 0 and frames_checked > 1000, "carried + ground + thief + lost + uncollected = 25 on every checked frame (%d frames, %d breaks)" % [frames_checked, invariant_breaks])

	print("--- Scenes load")
	for path in ["res://game/prototypes/p001_movement_camera.tscn", "res://game/prototypes/p002_gold_collection.tscn",
			"res://game/prototypes/p003_gold_power_burden.tscn", "res://game/prototypes/p004_gold_spill_theft.tscn", P005]:
		var packed: PackedScene = load(path)
		var inst: Node = packed.instantiate() if packed != null else null
		check(inst != null, "%s instantiates" % path.get_file())
		if inst != null:
			inst.free()

	print("=== %d passed, %d failed (%d checks)" % [passes, fails, passes + fails])
	quit(1 if fails > 0 else 0)
