extends SceneTree
## P004 regression checks: gold accounting and encounter mechanics only, never feel or fairness.
##
## Run from the repository root (Godot 4.7.2):
##   <godot> --headless --path . --script res://tests/p004_regression.gd
## Exit code 0 when every check passes, 1 otherwise.

const P004 := "res://game/prototypes/p004_gold_spill_theft.tscn"
const MOVES: Array[String] = ["move_left", "move_right", "move_up", "move_down"]
## Where scripted trials stand: inside the pocket and within the trigger radius of the burrow.
const ENGAGE := Vector3(6.5, 0, -9.5)

var passes: int = 0
var fails: int = 0
var scene: Node


func _initialize() -> void:
	# A script error inside the test coroutine stops it without quitting; fail instead of hanging.
	create_timer(420.0).timeout.connect(func() -> void:
		print("FAIL  watchdog: test did not finish (script error or stuck scenario)")
		quit(1))
	_run()


## Stops the thief and the trigger so transfers can be forced directly without the live encounter interfering.
func freeze_encounter(frozen: bool) -> void:
	scene.set_physics_process(not frozen)
	thief().set_physics_process(not frozen)


func check(cond: bool, msg: String) -> void:
	if cond:
		passes += 1
		print("PASS  ", msg)
	else:
		fails += 1
		print("FAIL  ", msg)


func wait(frames: int) -> void:
	for i in frames:
		await physics_frame


func wait_until(cond: Callable, max_frames: int) -> bool:
	for i in max_frames:
		if cond.call():
			return true
		await physics_frame
	return cond.call()


func load_fresh() -> void:
	if current_scene == null:
		change_scene_to_file(P004)
	else:
		reload_current_scene()
	await process_frame
	await process_frame
	await physics_frame
	scene = current_scene


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


## Walks toward a point each frame until within `tolerance`.
func walk_to(target: Vector3, max_frames: int = 240, tolerance: float = 0.15) -> void:
	for i in max_frames:
		var d := Vector2(target.x - player().global_position.x, target.z - player().global_position.z)
		if d.length() <= tolerance:
			break
		press(d.normalized())
		await physics_frame
	release_all()


## Chases the thief each frame until it is intercepted, escapes, or time runs out.
func chase(max_frames: int = 300) -> void:
	for i in max_frames:
		if scene.dropped > 0 or thief().state == thief().State.GONE:
			break
		var d := Vector2(thief().global_position.x - player().global_position.x, thief().global_position.z - player().global_position.z)
		press(d.normalized())
		await physics_frame
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


## Preset trial with the King standing at ENGAGE; returns once the thief has made contact.
func engage(key: Key) -> bool:
	await tap_key(key)
	await walk_to(ENGAGE)
	return await wait_until(func() -> bool: return thief().state == thief().State.PAUSE, 400)


func landed() -> bool:
	for c in scene.ground:
		if not c.collectable:
			return false
	return true


## Ledger snapshot used to compare repeated runs.
func record() -> Dictionary:
	return {"outcome": scene.outcome, "gold": scene.gold_total, "ground": scene.ground.size(), "spilled": scene.spilled,
		"recovered": scene.recovered, "stolen": scene.stolen, "dropped": scene.dropped, "lost": scene.lost,
		"thief_pos": thief().global_position.snapped(Vector3.ONE * 0.001)}


func _run() -> void:
	await load_fresh()
	var p = player()
	var t = thief()

	print("--- Baseline")
	check(ProjectSettings.get_setting("application/run/main_scene") == P004, "main scene is P004")
	check(scene.gold_total == 0 and scene.ledger_ok() and hud_ok(), "start: gold 0, ledger balanced, gold HUD and pouch in sync")
	check(t.state == t.State.IDLE and t.visible and flat(t.global_position, scene.get_node("Burrow").global_position) < 0.01, "thief idle and visible at its burrow")
	check(scene.get_node("Gold").get_child_count() == 20, "20 P002 level pickups present")
	check(p.move_speed == 5.0 and p.acceleration == 80.0 and p.deceleration == 120.0, "P001 movement values unchanged (5.0 / 80 / 120)")
	check(scene.get_node("HUD/EncounterLabel").visible and scene.get_node("HUD/EncounterLabel").text.begins_with("Thief: waiting"), "test HUD visible by default")
	check(scene.trigger_radius == 9.0 and scene.spill_cap == 3 and scene.steal_cap == 1 and t.warn_time == 1.0 and t.approach_speed == 3.0
		and t.give_up_time == 8.0 and t.contact_radius == 0.8 and t.pause_time == 0.5 and t.grab_speed == 3.5 and t.flee_speed == 3.5
		and t.claim_radius == 0.4 and t.intercept_radius == 1.0 and is_equal_approx(scene.hop_time, 0.3) and scene.preset_gold == [0, 10, 20],
		"starting tuning values as approved")
	var start: Vector3 = scene.get_node("EncounterStart").global_position
	check(flat(start, t.home_position()) > scene.trigger_radius and flat(ENGAGE, t.home_position()) < scene.trigger_radius, "preset start is outside the trigger radius; the scripted stand point is inside")

	print("--- Zero gold")
	await tap_key(KEY_1)
	check(scene.gold_total == 0 and p.global_position.distance_to(start) < 0.01, "key 1: gold 0, King at encounter start")
	teleport(t.home_position() + Vector3(-1.5, 0, 1.5))
	await wait(120)
	check(t.state == t.State.IDLE and not scene.encounter_used and scene.spilled == 0 and scene.gold_total == 0, "0 gold next to the thief: no encounter, no spill, no negative gold")
	check(scene.outcome == "no gold" and scene.ledger_ok(), "zero-gold case reported once; ledger balanced")

	print("--- Spill caps (contact forced directly)")
	freeze_encounter(true)
	for g in [0, 1, 2, 3, 10, 20]:
		scene.start_preset(g)
		teleport(Vector3(8, 0, -11))
		t.global_position = Vector3(8.8, 0, -11)
		scene._on_thief_contacted()
		var want: int = mini(3, g)
		check(scene.gold_total == g - want and scene.ground.size() == want and scene.spilled == want and scene.ledger_ok() and scene.gold_total >= 0,
			"carrying %d: spills %d, carries %d, ledger balanced" % [g, want, scene.gold_total])
	var spots_ok := true
	await wait(25)
	var lands: Array[Vector3] = []
	for c in scene.ground:
		lands.append(c.global_position)
		var inside: bool = c.global_position.x >= scene.coin_min.x - 0.001 and c.global_position.x <= scene.coin_max.x + 0.001 \
			and c.global_position.z >= scene.coin_min.y - 0.001 and c.global_position.z <= scene.coin_max.y + 0.001
		if not inside or flat(c.global_position, p.global_position) < 1.0:
			spots_ok = false
	check(spots_ok and lands.size() == 3 and lands[0].distance_to(lands[1]) > 1.0 and lands[1].distance_to(lands[2]) > 1.0, "spilled coins land separately, inside the pocket, at least 1 m from the King")
	check(landed(), "coins become collectable after the hop")

	print("--- Scatter, recovery, duplicates")
	scene.start_preset(5)
	teleport(Vector3(8, 0, -11))
	t.global_position = Vector3(8.8, 0, -11)
	scene._on_thief_contacted()
	var coin = scene.ground[0]
	var target: Vector3 = Vector3(8, 0, -11) + (Vector3(0.8, 0, 0).normalized().rotated(Vector3.UP, deg_to_rad(60.0)) * 1.6)
	teleport(target)
	await wait(8)
	check(scene.gold_total == 2 and not coin.popped and scene.ground.has(coin), "no collection while the coin is still scattering")
	await wait(20)
	check(scene.gold_total == 3 and coin.popped and not scene.ground.has(coin) and scene.recovered == 1, "landed coin under the King is recovered once, with feedback")
	check(not scene._try_recover(coin), "recovering the same coin again is refused")
	await wait(20)
	check(scene.gold_total == 3 and scene.recovered == 1 and scene.ledger_ok() and hud_ok(), "standing on it does not count it again; HUD and pouch match")

	print("--- Claim / pickup contention (same physics frame, both orders)")
	var c1 = scene.ground[0]
	var c2 = scene.ground[1]
	var sound_before: int = scene._last_sound_msec
	scene._on_thief_claim_attempted(c1)
	c1._on_body_entered(p)
	check(scene.stolen == 1 and scene.thief_held == 1 and scene.gold_total == 3 and not c1.popped and scene._last_sound_msec == sound_before and scene.ledger_ok(),
		"thief claims first: King gets nothing, no pop or pickup sound")
	check(t.holding == 1 and t.get_node("CarriedCoin").visible, "stolen-gold indicator shown on the thief")
	c2._on_body_entered(p)
	scene._on_thief_claim_attempted(c2)
	check(c2.popped and scene.gold_total == 4 and scene.stolen == 1 and scene.thief_held == 1 and scene.ledger_ok(), "King collects first: thief claim refused, King feedback plays")
	scene.start_preset(10)
	teleport(Vector3(8, 0, -11))
	t.global_position = Vector3(8.8, 0, -11)
	scene._on_thief_contacted()
	await wait(25)
	scene._on_thief_claim_attempted(scene.ground[0])
	scene._on_thief_claim_attempted(scene.ground[0])
	check(scene.stolen == 1 and scene.thief_held == 1 and scene.ground.size() == 2 and scene.ledger_ok(), "theft cap: a second claim is refused")
	scene._on_thief_intercepted()
	check(scene.thief_held == 0 and scene.dropped == 1 and scene.ground.size() == 3 and scene.ledger_ok(), "interception moves thief-held gold back to the ground")
	await wait(25)
	scene._on_thief_claim_attempted(scene.ground[2])
	check(scene.stolen == 1 and scene.thief_held == 0, "a dropped coin cannot be stolen again")

	freeze_encounter(false)

	print("--- Encounter: warning and avoidance")
	await tap_key(KEY_2)
	await walk_to(ENGAGE)
	check(t.state == t.State.ALERT and t.get_node("Alert").visible, "carrying gold inside the radius: thief shows its warning")
	var alert_pos: Vector3 = t.global_position
	await wait(30)
	check(t.state == t.State.ALERT and t.global_position == alert_pos, "thief does not move during the warning")
	await wait_until(func() -> bool: return t.state == t.State.APPROACH, 60)
	check(t.state == t.State.APPROACH and not t.get_node("Alert").visible, "after about 1 s the warning ends and the thief approaches")
	await walk_to(start, 120)
	var finished := await wait_until(func() -> bool: return t.state == t.State.GONE, 900)
	check(finished and scene.outcome == "avoided" and scene.spilled == 0 and scene.gold_total == 10 and scene.ledger_ok(), "retreating avoids contact; thief gives up; outcome avoided, gold kept")
	await walk_to(ENGAGE)
	await wait(120)
	check(t.state == t.State.GONE and scene.spilled == 0, "one encounter per reset: no second attempt")

	print("--- Encounter: contact and interception rules")
	var contact_ok := await engage(KEY_2)
	check(contact_ok and scene.spilled == 3 and scene.gold_total == 7 and scene.ledger_ok() and hud_ok(), "standing still: thief makes contact; 3 of 10 gold spill; HUD and pouch updated")
	check(t.get_node("Alert").visible == false and scene.ground.size() == 3, "spilled coins exist as ground pickups")
	await wait_until(func() -> bool: return t.state == t.State.GRAB, 60)
	teleport(t.global_position + Vector3(0.5, 0, 0))
	await wait(1)
	check(scene.dropped == 0 and scene.thief_held == 0, "King next to the thief during GRAB does not intercept")

	print("--- Encounter: no pursuit")
	await engage(KEY_2)
	await wait_until(func() -> bool: return scene.thief_held == 1, 120)
	check(scene.thief_held == 1 and flat(t.global_position, p.global_position) > t.intercept_radius, "thief claims a coin away from the King (no automatic interception)")
	check(scene.get_node("HUD/EncounterLabel").text.begins_with("Thief: fleeing with gold"), "test HUD follows the thief's state (fleeing with gold)")
	await wait_until(func() -> bool: return t.state == t.State.GONE, 600)
	check(scene.outcome == "escaped with gold" and scene.lost == 1 and scene.dropped == 0 and scene.ledger_ok(), "King standing still: thief escapes with 1 gold")
	check(scene.gold_total == 7 and scene.ground.size() == 2 and not t.visible, "escape removes only the stolen coin; the other 2 stay recoverable")
	var no_pursuit: Dictionary = record()

	print("--- Encounter: prompt pursuit")
	var prompt_runs: Array = []
	for r in 2:
		await engage(KEY_2)
		await wait_until(func() -> bool: return scene.thief_held == 1, 120)
		await chase()
		await wait_until(func() -> bool: return t.state == t.State.GONE, 600)
		prompt_runs.append(record())
	var prompt: Dictionary = prompt_runs[0]
	check(prompt["outcome"] == "intercepted" and prompt["dropped"] == 1 and prompt["lost"] == 0 and scene.ledger_ok(), "chasing as soon as the thief takes a coin intercepts it")
	check(prompt_runs[0] == prompt_runs[1], "repeated prompt-pursuit trials give identical results")
	await engage(KEY_2)
	await wait_until(func() -> bool: return scene.thief_held == 1, 120)
	await chase()
	var drop_coin = scene.ground[scene.ground.size() - 1]
	await wait(25)
	await walk_to(drop_coin.global_position, 120, 0.1)
	await wait(5)
	check(drop_coin.popped and scene.ledger_ok() and hud_ok(), "the dropped coin is recovered with normal feedback")

	print("--- Encounter: delayed pursuit")
	await engage(KEY_2)
	await wait_until(func() -> bool: return scene.thief_held == 1, 120)
	await wait(90)
	await chase()
	await wait_until(func() -> bool: return t.state == t.State.GONE, 600)
	check(scene.outcome == "escaped with gold" and scene.lost == 1 and scene.ledger_ok(), "chasing 1.5 s late lets the thief escape")
	await engage(KEY_2)
	await wait_until(func() -> bool: return scene.thief_held == 1, 120)
	await wait(30)
	await chase()
	await wait_until(func() -> bool: return t.state == t.State.GONE, 600)
	print("      chase 0.5 s late: ", scene.outcome)

	print("--- Encounter: recovery before theft")
	scene.start_preset(1)
	await walk_to(ENGAGE)
	await wait_until(func() -> bool: return t.state == t.State.PAUSE, 400)
	await wait_until(func() -> bool: return landed(), 30)
	await walk_to(scene.ground[0].global_position, 60, 0.1)
	await wait_until(func() -> bool: return t.state == t.State.GONE, 600)
	check(scene.outcome == "recovered before theft" and scene.stolen == 0 and scene.gold_total == 1 and scene.ledger_ok(), "collecting the spilled coin first: thief leaves empty-handed")
	var race: Array = []
	await engage(KEY_2)
	await wait_until(func() -> bool: return landed(), 30)
	while not scene.ground.is_empty() and scene.thief_held == 0 and scene.stolen == 0:
		var nearest = null
		for c in scene.ground:
			if nearest == null or flat(c.global_position, t.global_position) < flat(nearest.global_position, t.global_position):
				nearest = c
		await walk_to(nearest.global_position, 60, 0.1)
		race.append(scene.recovered)
	await wait_until(func() -> bool: return t.state == t.State.GONE, 600)
	print("      3-coin race (King takes the coin nearest the thief first): ", scene.outcome, ", recovered ", scene.recovered, ", stolen ", scene.stolen)
	check(scene.ledger_ok(), "ledger balanced after the 3-coin race")

	print("--- Resets")
	await engage(KEY_3)
	await wait_until(func() -> bool: return scene.thief_held == 1, 120)
	await tap_key(KEY_2)
	check(scene.gold_total == 10 and scene.haul_start == 10 and scene.ground.is_empty() and scene.thief_held == 0 and scene.lost == 0
		and scene.spilled == 0 and scene.stolen == 0 and scene.dropped == 0 and not scene.encounter_used and scene.outcome == "", "key 2 mid-theft: ledger and counters reset")
	check(t.state == t.State.IDLE and t.visible and not t.get_node("CarriedCoin").visible and not t.get_node("Alert").visible
		and flat(t.global_position, t.home_position()) < 0.01, "thief back at the burrow, idle, indicator cleared")
	await wait(2)
	check(scene.get_node("SpillCoins").get_child_count() == 0, "spilled coins removed")
	check(p.global_position.distance_to(start) < 0.05 and scene.ledger_ok() and hud_ok(), "King at the start; HUD and pouch at 10")
	await engage(KEY_2)
	await wait_until(func() -> bool: return t.state == t.State.GONE, 900)
	check(record() == no_pursuit, "after a reset the same inputs give the same encounter")

	print("--- Level coins during presets")
	await tap_key(KEY_2)
	var north1 = scene.get_node("Gold/North1")
	teleport(north1.global_position)
	await wait(3)
	check(scene.level_collected == 1 and scene.gold_total == 11 and scene.ledger_ok(), "a level coin collected during a trial counts as level gold")
	await tap_key(KEY_2)
	await wait(3)
	var remaining := 0
	for c in scene.get_node("Gold").get_children():
		if not c._collected:
			remaining += 1
	check((not is_instance_valid(north1) or north1._collected) and scene.level_collected == 0 and scene.gold_total == 10 and scene.ledger_ok(),
		"preset reset keeps collected level coins collected and starts a new haul")
	check(remaining == 19, "other level pickups untouched (%d uncollected)" % remaining)

	print("--- Full reload (R)")
	var old := scene
	await tap_key(KEY_R)
	await process_frame
	scene = current_scene
	p = player()
	t = thief()
	check(scene != old and scene.gold_total == 0 and scene.get_node("Gold").get_child_count() == 20 and t.state == t.State.IDLE and scene.ledger_ok(),
		"R: full reload restores gold 0, all 20 level coins, idle thief")

	print("--- P001/P002 regression in P004")
	for g in [0, 10, 20]:
		scene.start_preset(g)
		var straight := await top_speed(Vector2(1, 0))
		var diagonal := await top_speed(Vector2(1, -1).normalized())
		check(absf(straight - 5.0) < 0.01 and absf(diagonal - 5.0) < 0.01, "carrying %d: top speed %.3f, diagonal %.3f" % [g, straight, diagonal])
	scene.start_preset(10)
	freeze_encounter(true)
	teleport(Vector3(8, 0, -11))
	t.global_position = Vector3(8.8, 0, -11)
	scene._on_thief_contacted()
	var after_spill := await top_speed(Vector2(1, 0))
	check(absf(after_spill - 5.0) < 0.01 and p.move_speed == 5.0, "top speed still 5.0 after a spill")
	teleport(Vector3(-13, 0, 13.5))
	press(Vector2(1, 0))
	await physics_frame
	var first_step: float = p.velocity.length()
	await wait(10)
	release_all()
	var v_top: float = p.velocity.length()
	await physics_frame
	check(absf(first_step - 80.0 / 60.0) < 0.01 and absf(v_top - p.velocity.length() - 2.0) < 0.01, "acceleration and deceleration steps unchanged")
	teleport(Vector3(13, 0, 0))
	await drive(Vector2(1, 0), 60)
	check(p.global_position.x <= 14.56 and p.global_position.x > 14.4, "east wall blocks")
	teleport(Vector3(5.75, 0, -1.5))
	await drive(Vector2(0, -1), 120)
	check(p.global_position.z < -8.0, "narrow passage passable")
	await drive(Vector2(-1, 0), 10)
	check(p.get_node("Visual").flip_h, "facing flips left on input")
	await wait(4)
	await process_frame
	await process_frame
	var pitch := deg_to_rad(52.0)
	check((scene.get_node("Camera") as Node3D).global_position.distance_to(p.global_position + Vector3(0, sin(pitch), cos(pitch)) * 12.0) < 0.01, "camera follow offset unchanged")
	await load_fresh()
	p = player()
	var level := scene.get_node("Gold/Isolated")
	teleport(level.global_position)
	await wait(3)
	await wait(10)
	check(scene.gold_total == 1 and scene.level_collected == 1 and hud_ok() and scene.ledger_ok(), "level pickup collects once; gold HUD and pouch update")
	# The Inspector toggle, as set before the scene starts.
	var hidden_hud: Node = (load(P004) as PackedScene).instantiate()
	hidden_hud.show_test_hud = false
	root.add_child(hidden_hud)
	await process_frame
	check(not hidden_hud.get_node("HUD/EncounterLabel").visible and hidden_hud.get_node("HUD/GoldLabel").visible, "Show Test HUD off hides the encounter line; gold counter stays")
	hidden_hud.free()

	print("--- Scenes load")
	for path in ["res://game/prototypes/p001_movement_camera.tscn", "res://game/prototypes/p002_gold_collection.tscn",
			"res://game/prototypes/p003_gold_power_burden.tscn", P004]:
		var packed: PackedScene = load(path)
		var inst: Node = packed.instantiate() if packed != null else null
		check(inst != null, "%s instantiates" % path.get_file())
		if inst != null:
			inst.free()

	print("=== %d passed, %d failed (%d checks)" % [passes, fails, passes + fails])
	quit(1 if fails > 0 else 0)
