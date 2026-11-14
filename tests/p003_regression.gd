extends SceneTree
## P003 regression checks: mechanical behavior only, never feel or balance.
## Runs every check once with Stronger Burden off (Original) and once with it on.
##
## Run from the repository root (Godot 4.7.2):
##   <godot> --headless --path . --script res://tests/p003_regression.gd
## Exit code 0 when every check passes, 1 otherwise.

const P003 := "res://game/prototypes/p003_gold_power_burden.tscn"
const MOVES: Array[String] = ["move_left", "move_right", "move_up", "move_down"]
const STATES: Array[String] = ["Light", "Loaded", "Heavy"]
const ORIGINAL_SPEEDS: Array[float] = [5.0, 4.6, 4.2]
const STRONGER_SPEEDS: Array[float] = [5.0, 4.4, 3.8]
const IMPACTS: Array[int] = [2, 3, 6]
const HITS_TO_BREAK: Array[int] = [3, 2, 1]
const PRESET_GOLD: Array[int] = [0, 10, 20]

var passes: int = 0
var fails: int = 0
var stronger: bool = false
var scene: Node


func _initialize() -> void:
	_run()


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


func load_fresh() -> void:
	if current_scene == null:
		change_scene_to_file(P003)
	else:
		reload_current_scene()
	await process_frame
	await process_frame
	await physics_frame
	scene = current_scene
	scene.stronger_burden = stronger


## Untyped so the P001 player script's properties (acceleration, move_speed) are reachable.
func player():
	return scene.get_node("Player")


func trial_text() -> String:
	return (scene.get_node("HUD/TrialLabel") as Label).text


func config() -> String:
	return "Stronger burden" if stronger else "Original"


func speeds() -> Array[float]:
	return STRONGER_SPEEDS if stronger else ORIGINAL_SPEEDS


func release_all() -> void:
	for a in MOVES:
		Input.action_release(a)
	Input.action_release("strike")


func press(v: Vector2) -> void:
	for a in MOVES:
		Input.action_release(a)
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


func strike_once() -> void:
	Input.action_press("strike")
	await physics_frame
	Input.action_release("strike")
	await physics_frame


func set_gold(gold: int) -> void:
	scene.gold_total = gold
	scene._show_total()


func expected_state(gold: int) -> int:
	return 2 if gold >= 14 else (1 if gold >= 6 else 0)


func pouch_ok(gold: int) -> bool:
	var pouch: Node = scene.get_node("Player/Pouch")
	var tex: Texture2D = pouch.low_texture
	if gold >= pouch.overflowing_at: tex = pouch.overflowing_texture
	elif gold >= pouch.partial_at: tex = pouch.partial_texture
	return pouch.texture == tex


## Highest horizontal speed reached in 40 frames of held input, in the open south-west corner.
func top_speed(v: Vector2) -> float:
	teleport(Vector3(-13, 0, 13.5))
	press(v)
	var best := 0.0
	for i in 40:
		await physics_frame
		best = maxf(best, Vector2(player().velocity.x, player().velocity.z).length())
	release_all()
	return best


## Scripted run: hold left and strike every other frame while the target is intact and in reach.
func run_course(max_frames: int = 900) -> Dictionary:
	var gold_start: int = scene.gold_total
	var target: Node = scene.get_node("Course/CourseTarget")
	var gold_changed := false
	press(Vector2(-1, 0))
	for i in max_frames:
		if not target.broken and player().global_position.x < 1.2 and i % 2 == 0:
			Input.action_press("strike")
		else:
			Input.action_release("strike")
		await physics_frame
		if scene.gold_total != gold_start: gold_changed = true
		if scene.trial == scene.Trial.FINISHED: break
	release_all()
	return {"finished": scene.trial == scene.Trial.FINISHED, "ticks": scene.trial_ticks,
		"hits": scene.strike_hits, "gold_changed": gold_changed}


func capsule_free(pos: Vector3) -> bool:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.45
	shape.height = 1.5
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = shape
	q.transform = Transform3D(Basis(), pos + Vector3(0, 0.76, 0))
	q.exclude = [player().get_rid()]
	return player().get_world_3d().direct_space_state.intersect_shape(q, 1).is_empty()


func _run() -> void:
	await load_fresh()
	print("--- Defaults")
	scene.stronger_burden = false
	check(scene.config_name() == "Original", "Stronger Burden toggle can be off (Original)")
	check([scene.light_speed, scene.loaded_speed, scene.heavy_speed] == ORIGINAL_SPEEDS, "original speeds 5.0 / 4.6 / 4.2")
	check([scene.stronger_light_speed, scene.stronger_loaded_speed, scene.stronger_heavy_speed] == STRONGER_SPEEDS, "stronger-burden speeds 5.0 / 4.4 / 3.8")
	check([scene.light_impact, scene.loaded_impact, scene.heavy_impact] == IMPACTS, "impacts 2 / 3 / 6")
	check(scene.loaded_at == 6 and scene.heavy_at == 14, "thresholds 6 / 14")
	reload_current_scene()
	await process_frame
	await process_frame
	check(current_scene.stronger_burden == false, "Stronger Burden is off in the saved scene")

	for mode in [false, true]:
		stronger = mode
		await _suite()

	print("=== %d passed, %d failed (%d checks)" % [passes, fails, passes + fails])
	quit(1 if fails > 0 else 0)


func _suite() -> void:
	print("=== Configuration: ", config())
	await load_fresh()
	var p = player()
	var strike: Node = p.get_node("Strike")
	var sp := speeds()

	print("--- Start state and P001 baseline")
	check(p.acceleration == 80.0 and p.deceleration == 120.0, "P001 acceleration 80 / deceleration 120 unchanged")
	check(scene.gold_total == 0 and scene.wealth == 0 and is_equal_approx(p.move_speed, 5.0) and strike.impact == 2, "start: gold 0, Light, 5.0 m/s, impact 2")
	check(trial_text().begins_with("Config: " + config()), "trial HUD names the configuration")
	check(scene.get_node("Gold").get_child_count() == 20, "20 P002 pickups present")

	print("--- Thresholds, HUD and gold synchronisation")
	for gold in [0, 5, 6, 13, 14, 20]:
		set_gold(gold)
		var s := expected_state(gold)
		var ok: bool = scene.wealth == s and is_equal_approx(p.move_speed, sp[s]) and strike.impact == IMPACTS[s]
		ok = ok and (scene.get_node("HUD/GoldLabel") as Label).text == "Gold: %d" % gold and pouch_ok(gold)
		ok = ok and trial_text().contains("%s | speed %.1f" % [STATES[s], sp[s]])
		check(ok, "gold %d -> %s, %.1f m/s, impact %d; gold label, pouch and trial HUD in sync" % [gold, STATES[s], sp[s], IMPACTS[s]])
	var other: Array[float] = ORIGINAL_SPEEDS if stronger else STRONGER_SPEEDS
	set_gold(20)
	scene.stronger_burden = not stronger
	var flipped: bool = is_equal_approx(p.move_speed, other[2]) and strike.impact == 6
	scene.stronger_burden = stronger
	check(flipped and is_equal_approx(p.move_speed, sp[2]) and trial_text().begins_with("Config: " + config()), "toggling the configuration updates speed and HUD immediately; impact unchanged")

	print("--- Natural collection across thresholds (P002 pickups)")
	await load_fresh()
	p = player()
	strike = p.get_node("Strike")
	var positions: Array[Vector3] = []
	for c: Node3D in scene.get_node("Gold").get_children():
		positions.append(c.global_position)
	var first := positions[0]
	teleport(first)
	await wait(3)
	check(scene.gold_total == 1 and (scene.get_node("HUD/GoldLabel") as Label).text == "Gold: 1", "a pickup collects once and updates the gold label")
	await wait(10)
	check(scene.gold_total == 1, "standing on a collected pickup does not count it again")
	var sync_ok := true
	var seen: Array[int] = []
	for i in range(1, 16):
		teleport(positions[i])
		await wait(3)
		var gold: int = scene.gold_total
		seen.append(gold)
		var s := expected_state(gold)
		if scene.wealth != s or not is_equal_approx(p.move_speed, sp[s]) or strike.impact != IMPACTS[s] or not pouch_ok(gold):
			sync_ok = false
	check(sync_ok and seen.has(6) and seen.has(14), "state, speed, impact and pouch follow the total across 6 and 14 %s" % [seen])

	print("--- Movement: only top speed changes")
	for s in 3:
		set_gold(PRESET_GOLD[s])
		var straight := await top_speed(Vector2(1, 0))
		var diagonal := await top_speed(Vector2(1, -1).normalized())
		check(absf(straight - sp[s]) < 0.01 and absf(diagonal - sp[s]) < 0.01, "%s top speed %.3f, diagonal %.3f (expected %.1f)" % [STATES[s], straight, diagonal, sp[s]])
		teleport(Vector3(-13, 0, 13.5))
		press(Vector2(1, 0))
		await physics_frame
		var first_step: float = p.velocity.length()
		await wait(10)
		release_all()
		var v_top: float = p.velocity.length()
		await physics_frame
		var decel_step: float = v_top - p.velocity.length()
		check(absf(first_step - 80.0 / 60.0) < 0.01 and absf(decel_step - 120.0 / 60.0) < 0.01, "%s acceleration step %.3f and deceleration step %.3f unchanged" % [STATES[s], first_step, decel_step])
	set_gold(20)
	teleport(Vector3(13, 0, 0))
	await drive(Vector2(1, 0), 60)
	check(p.global_position.x <= 14.56 and p.global_position.x > 14.4, "Heavy: P001 east wall still blocks")
	teleport(Vector3(5.75, 0, -1.5))
	await drive(Vector2(0, -1), 120)
	check(p.global_position.z < -8.0, "Heavy: P001 narrow passage still passable")
	await drive(Vector2(-1, 0), 10)
	check(p.get_node("Visual").flip_h, "P001 facing flips left on input")
	await wait(4)
	await process_frame
	await process_frame
	var pitch := deg_to_rad(52.0)
	var cam_target: Vector3 = p.global_position + Vector3(0, sin(pitch), cos(pitch)) * 12.0
	check((scene.get_node("Camera") as Node3D).global_position.distance_to(cam_target) < 0.01, "P001 camera follow offset unchanged")

	print("--- Strike, cooldown and target hit counts")
	var attempts: Array[int] = [0]
	strike.attempted.connect(func() -> void: attempts[0] += 1)
	var practice: Node3D = scene.get_node("PracticeTarget")
	check(practice.toughness == 6 and scene.get_node("Course/CourseTarget").toughness == 6, "target toughness 6")
	for s in 3:
		set_gold(PRESET_GOLD[s])
		practice.restore()
		teleport(practice.global_position + Vector3(0.95, 0, 0))
		var n := 0
		while not practice.broken and n < 10:
			await strike_once()
			n += 1
			await wait(20)
		check(practice.broken and n == HITS_TO_BREAK[s], "%s breaks the practice target in %d strike(s)" % [STATES[s], n])
	check(strike.cooldown == 0.3, "strike cooldown 0.3 s")
	set_gold(0)
	await wait(30)
	attempts[0] = 0
	await strike_once()
	await strike_once()
	await wait(6)
	await strike_once()
	check(attempts[0] == 1, "presses within 0.3 s give one strike (got %d)" % attempts[0])
	await wait(20)
	await strike_once()
	check(attempts[0] == 2, "strike available again after the cooldown")

	print("--- Preset keys reset the strike cooldown")
	for k: Key in [KEY_1, KEY_2, KEY_3]:
		await strike_once()
		var before: int = attempts[0]
		var was_cooling: bool = strike._cooldown_left > 0.0
		await tap_key(k)
		await strike_once()
		var immediate: bool = attempts[0] == before + 1
		await strike_once()
		check(was_cooling and immediate and attempts[0] == before + 1, "key %s: first strike immediate, then the normal cooldown applies" % OS.get_keycode_string(k))

	print("--- Course: blocking, gate and trials")
	await tap_key(KEY_1)
	var target: Node3D = scene.get_node("Course/CourseTarget")
	var gate: Node3D = scene.get_node("Course/Gate")
	check(scene.trial == scene.Trial.READY and p.global_position.distance_to(scene.get_node("Course/StartMarker").global_position) < 0.01, "key 1: King at the start marker, trial ready")
	await drive(Vector2(-1, 0), 90)
	check(not target.broken and p.global_position.x > 0.83, "intact course target blocks the lane")
	check(scene.trial == scene.Trial.RUNNING, "crossing the start line starts the timer")

	# Gate in isolation, with the controller clock paused.
	scene.set_physics_process(false)
	var sched: Array[bool] = []
	for t in [0.0, 0.99, 1.0, 1.99, 2.0, 3.0]:
		sched.append(gate.scheduled_closed(t))
	check(sched == [true, true, false, false, true, false], "gate schedule: closed 1 s, open 1 s, repeating")
	target.remove()
	var gx: float = gate.global_position.x
	teleport(Vector3(gx + 1.5, 0, -13.875))
	for i in 60:
		gate.set_trial_time(0.5)
		press(Vector2(-1, 0))
		await physics_frame
	release_all()
	check(gate.is_closed and p.global_position.x > gx + 0.64, "closed gate blocks")
	for i in 40:
		gate.set_trial_time(1.5)
		press(Vector2(-1, 0))
		await physics_frame
	release_all()
	check(not gate.is_closed and p.global_position.x < gx - 1.0, "open gate lets the King through")
	teleport(Vector3(gx, 0, -13.875))
	gate.set_trial_time(1.5)
	await physics_frame
	gate.set_trial_time(0.5)
	await physics_frame
	check(not gate.is_closed, "gate does not close while the King stands in it")
	await drive(Vector2(-1, 0), 20)
	gate.set_trial_time(0.5)
	await physics_frame
	check(gate.is_closed and capsule_free(p.global_position), "gate closes once he is clear, without trapping him")
	scene.set_physics_process(true)

	for s in 3:
		var key: Key = [KEY_1, KEY_2, KEY_3][s]
		await tap_key(key)
		var a: Dictionary = await run_course()
		await tap_key(key)
		var b: Dictionary = await run_course()
		check(a["finished"] and a["hits"] == HITS_TO_BREAK[s] and not a["gold_changed"], "%s completes the course; target took %d hit(s); gold constant" % [STATES[s], a["hits"]])
		check(a == b, "%s: repeated scripted runs give identical results (%.2f s)" % [STATES[s], a["ticks"] / 60.0])

	print("--- Resets")
	await tap_key(KEY_3)
	await drive(Vector2(-1, 0), 30)
	await tap_key(KEY_2)
	var pouch: Node = scene.get_node("Player/Pouch")
	check(scene.trial == scene.Trial.READY and scene.trial_ticks == 0 and scene.gate_ticks == 0 and scene.strike_attempts == 0, "key 2 mid-trial: timer and counters zeroed")
	check(not target.broken and gate.is_closed, "key 2: target restored, gate back to its initial phase")
	check(scene.gold_total == 10 and pouch.texture == pouch.partial_texture and is_equal_approx(p.move_speed, sp[1]) and strike.impact == 3, "key 2: gold 10, pouch, Loaded speed and impact")
	check(scene.stronger_burden == stronger and trial_text().begins_with("Config: " + config()), "key 2: configuration unchanged")
	var old := scene
	await tap_key(KEY_R)
	await process_frame
	scene = current_scene
	p = player()
	check(scene != old and scene.gold_total == 0 and scene.wealth == 0 and scene.trial == scene.Trial.IDLE, "R: full reload to gold 0, Light, trial idle")
	check(p.global_position.distance_to(Vector3(0, 0, 8)) < 0.01, "R: King back at the P001 start")
