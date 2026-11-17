extends SceneTree
## P007 regression checks: scene isolation, eight-direction facing, sector geometry, sword timing
## and hit limits, dodge, invulnerability, cancellation, enemy states and first-contact strike
## resolution, defeat, retry, and input isolation; plus Iteration 1 target focus (Mode B):
## acquisition, release, snapped target facing, sword and dodge interaction, A/B mode selection,
## and comparison logging. Mechanical only; never feel, readability, fairness, balance, or enjoyment.
##
## Run from the repository root (Godot 4.7.2):
##   <godot> --headless --path . --script res://tests/p007_regression.gd
## Exit code 0 when every check passes, 1 otherwise.

const P007 := "res://game/prototypes/p007_combat_foundation.tscn"
const CombatSector := preload("res://game/prototypes/p007/combat_sector.gd")
const MOVES: Array[String] = ["move_left", "move_right", "move_up", "move_down"]
const TICK: float = 1.0 / 60.0

var passes: int = 0
var fails: int = 0


func _initialize() -> void:
	create_timer(600.0).timeout.connect(func() -> void:
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
	release_all()
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


func scene() -> Node:
	return current_scene


## Untyped so the subclass properties are reachable without preloading game scripts here.
func king() -> Variant:
	return current_scene.get_node("King")


func enemy() -> Variant:
	return current_scene.get_node("TrainingEnemy")


## Puts the King and enemy at exact spots with the enemy frozen (F4 behaviour), King idle.
func place(king_pos: Vector3, enemy_pos: Vector3) -> void:
	var e: Variant = enemy()
	e.held = true
	e.global_position = enemy_pos
	king().global_position = king_pos
	king().velocity = Vector3.ZERO
	await wait(1)


## Faces the King along an index by a few ticks of input, then releases input and stops him.
func face(index: int) -> void:
	var dir: Vector3 = king().direction_for_index(index)
	var pos: Vector3 = king().global_position
	hold_input(Vector2(dir.x, dir.z))
	await wait(2)
	hold_input(Vector2.ZERO)
	king().global_position = pos
	king().velocity = Vector3.ZERO
	await wait(1)


## Note on timing: SceneTree.physics_frame fires before nodes process that tick, and an action
## pressed now is first seen as "just pressed" on the next tick. So a tap has been handled by the
## game once tap() returns (two awaits).
func tap(action: String) -> void:
	Input.action_press(action)
	await physics_frame
	Input.action_release(action)
	await physics_frame


func release_all() -> void:
	for action: String in MOVES + ["attack", "dodge", "restart_test", "target_focus"]:
		if InputMap.has_action(action):
			Input.action_release(action)


func hold_input(v: Vector2) -> void:
	for action: String in MOVES:
		Input.action_release(action)
	if v.x > 0.0: Input.action_press("move_right", v.x)
	if v.x < 0.0: Input.action_press("move_left", -v.x)
	if v.y > 0.0: Input.action_press("move_down", v.y)
	if v.y < 0.0: Input.action_press("move_up", -v.y)


func flat(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)


func _run() -> void:
	await load_fresh()
	await test_isolation()
	await test_facing()
	test_sector_geometry()
	await test_sword()
	await test_dodge()
	await test_iframes()
	await test_cancel()
	await test_input_isolation()
	await test_enemy_states()
	await test_strike_resolution()
	await test_enemy_limits()
	await test_encounter_and_retry()
	await test_focus_acquisition()
	await test_focus_lifecycle()
	await test_focus_facing()
	await test_focus_sword()
	await test_focus_dodge()
	await test_focus_inputs()
	await test_focus_mode_and_logging()
	print("\n%d passed, %d failed" % [passes, fails])
	quit(0 if fails == 0 else 1)


func test_isolation() -> void:
	print("-- scene isolation")
	var root: Node = scene()
	check(root != null and root.scene_file_path == P007, "P007 scene loads directly")
	var kings: int = 0
	for node: Node in root.find_children("*", "CharacterBody3D", true, false):
		if node.name == "King":
			kings += 1
	check(kings == 1, "exactly one King")
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://game/prototypes/p006_meaningful_extraction_rewards.tscn", "default main scene is still P006")
	var text: String = FileAccess.get_file_as_string(P007)
	check(not text.contains("p006") and not text.contains("p004") and not text.contains("p005"), "P007 scene references no P004-P006 resources")
	var camera: Camera3D = root.get_node("Camera") as Camera3D
	check(is_zero_approx(camera.global_rotation.y), "camera never yaws, so world-plane input is camera-relative")
	var k: Variant = king()
	check(k.get_node("CollisionShape3D") != null and k.find_children("*", "CollisionShape3D", true, false).size() == 1, "King keeps player.tscn's single collision shape")


func test_facing() -> void:
	print("-- eight-direction facing")
	await load_fresh()
	var k: Variant = king()
	check(k.facing_index == 6, "starts facing up")
	var cases: Array = [
		[Vector2(1, 0), 0], [Vector2(1, 1), 1], [Vector2(0, 1), 2], [Vector2(-1, 1), 3],
		[Vector2(-1, 0), 4], [Vector2(-1, -1), 5], [Vector2(0, -1), 6], [Vector2(1, -1), 7]]
	for c: Array in cases:
		var v: Vector2 = c[0]
		hold_input(v)
		await wait(3)
		var expected: Vector3 = Vector3(v.x, 0, v.y).normalized()
		check(k.facing_index == c[1] and k.facing_dir.is_equal_approx(expected), "input %s faces index %d" % [v, c[1]])
	# Diagonal speed is capped at move_speed (normalized), not sqrt(2) faster.
	await load_fresh()
	k = king()
	hold_input(Vector2(1, -1))
	await wait(20)
	var speed: float = flat(k.velocity).length()
	check(speed <= k.move_speed + 0.01 and speed >= k.move_speed - 0.2, "diagonal speed is normalized (%.2f m/s)" % speed)
	hold_input(Vector2.ZERO)
	await wait(10)
	check(k.facing_index == 7, "neutral input keeps the last facing")
	# Weak stick input (inside the facing deadzone after the action deadzone) never turns the King.
	Input.action_press("move_left", 0.3)
	await wait(5)
	check(k.facing_index == 7, "input of 0.3 does not change facing (drift guard)")
	Input.action_release("move_left")
	# Near the 22.5-degree boundaries the snap is deterministic: nearest 45-degree direction.
	var near_lo: Vector2 = Vector2.from_angle(deg_to_rad(22.4))
	var near_hi: Vector2 = Vector2.from_angle(deg_to_rad(22.6))
	check(k.snap_index(near_lo) == 0 and k.snap_index(near_hi) == 1, "22.4 deg snaps right, 22.6 deg snaps down-right")
	check(k.snap_index(Vector2.from_angle(deg_to_rad(-22.6))) == 7, "-22.6 deg snaps up-right")
	# Walking moves at move_speed, once per tick (no duplicated movement).
	await load_fresh()
	k = king()
	var start: Vector3 = k.global_position
	hold_input(Vector2(1, 0))
	await wait(60)
	hold_input(Vector2.ZERO)
	var travelled: float = flat(k.global_position - start).length()
	check(travelled > k.move_speed * 0.9 and travelled < k.move_speed * 1.02, "one second of walking covers ~move_speed (%.2f m), not double" % travelled)
	# Walls stop the King.
	hold_input(Vector2(1, 0))
	await wait(180)
	hold_input(Vector2.ZERO)
	check(k.global_position.x < 6.0 - 0.4, "east wall stops the King (x = %.2f)" % k.global_position.x)


func test_sector_geometry() -> void:
	print("-- sector geometry")
	var o: Vector3 = Vector3.ZERO
	var up: Vector3 = Vector3(0, 0, -1)
	check(CombatSector.contains(o, up, 1.4, 110.0, Vector3(0, 0, -1.0)), "point ahead inside reach is inside")
	check(not CombatSector.contains(o, up, 1.4, 110.0, Vector3(0, 0, 1.0)), "point behind is outside")
	check(CombatSector.contains(o, up, 1.4, 110.0, Vector3(0, 0, -1.4)), "point exactly at reach is inside (inclusive)")
	check(not CombatSector.contains(o, up, 1.4, 110.0, Vector3(0, 0, -1.41)), "point just past reach is outside")
	var edge: Vector3 = Vector3(sin(deg_to_rad(55.0)), 0, -cos(deg_to_rad(55.0)))
	check(CombatSector.contains(o, up, 1.4, 110.0, edge), "point exactly on the 55-degree arc edge is inside")
	var past_edge: Vector3 = Vector3(sin(deg_to_rad(56.0)), 0, -cos(deg_to_rad(56.0)))
	check(not CombatSector.contains(o, up, 1.4, 110.0, past_edge), "point at 56 degrees is outside a 110-degree arc")
	check(not CombatSector.contains(o, up, 1.4, 110.0, Vector3(1.2, 0, 0)), "point to the side (90 degrees) is outside")
	var diag: Vector3 = Vector3(1, 0, -1).normalized()
	check(CombatSector.contains(o, diag, 1.4, 110.0, diag * 1.3) and not CombatSector.contains(o, diag, 1.4, 110.0, -diag * 0.5), "diagonal sector: ahead inside, behind outside")
	check(CombatSector.contains(o, up, 1.4, 110.0, Vector3(0, 5.0, -1.0)), "height is ignored (ground-plane test)")
	# The drawn mesh uses the same reach and arc: its far vertices sit exactly on the tested edge.
	var mesh: ArrayMesh = CombatSector.build_mesh(1.4, 110.0)
	var verts: PackedVector3Array = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var all_on_edge: bool = true
	var yaw: float = CombatSector.yaw_for(up)
	for v: Vector3 in verts:
		var world: Vector3 = v.rotated(Vector3.UP, yaw)
		if not CombatSector.contains(o, up, 1.4, 110.0, world):
			all_on_edge = false
	check(all_on_edge, "every drawn arc vertex, rotated to the facing, lies inside the tested sector")
	check(is_equal_approx(Vector3(1, 0, 0).rotated(Vector3.UP, yaw).z, -1.0), "yaw_for points mesh forward along the facing")


func test_sword() -> void:
	print("-- sword timing, direction lock, hit limits")
	await load_fresh()
	var k: Variant = king()
	var e: Variant = enemy()
	check(e.health == 3 and e.max_health == 3, "enemy starts with 3 health")
	# Straight: enemy 1.0 m ahead (up).
	await place(Vector3(0, 0, 2), Vector3(0, 0, 1))
	await face(6)
	var hp: int = e.health
	Input.action_press("attack")
	await wait(2)
	check(k.attack_phase == 1 and k.swings == 1, "press starts a swing in windup")
	check(k.attack_dir.is_equal_approx(Vector3(0, 0, -1)), "attack direction snapshot = facing")
	await wait(1)
	check(e.health == hp, "no damage during windup")
	var hit_tick: int = -1
	for i in 30:
		await physics_frame
		if e.health < hp and hit_tick < 0:
			hit_tick = i
	check(e.health == hp - 1, "enemy inside the arc for the whole active window takes exactly 1 hit")
	check(k.attack_phase == 0, "swing returns to idle after ~0.40 s")
	# Held attack: 60 more ticks of holding produce no new swing.
	await wait(60)
	check(k.swings == 1 and e.health == hp - 1, "holding attack does not chain swings")
	Input.action_release("attack")
	await wait(1)
	# Key-repeat (echo) events do not start a swing.
	var echo: InputEventKey = InputEventKey.new()
	echo.physical_keycode = KEY_J
	echo.keycode = KEY_J
	echo.pressed = true
	Input.parse_input_event(echo)
	await wait(30)
	var after_first: int = k.swings
	check(k.attack_phase == 0, "swing from the key press has finished before the echo arrives")
	var echo2: InputEventKey = echo.duplicate()
	echo2.echo = true
	Input.parse_input_event(echo2)
	await wait(2)
	check(k.swings == after_first, "a key-repeat echo does not start another swing")
	var up: InputEventKey = echo.duplicate()
	up.pressed = false
	Input.parse_input_event(up)
	await wait(30)
	# Mid-swing presses are ignored and do not extend timing.
	await place(Vector3(0, 0, 2), Vector3(0, 0, 1))
	await face(6)
	var swings_before: int = k.swings
	await tap("attack")
	await wait(3)
	await tap("attack")
	await wait(3)
	await tap("attack")
	await wait(30)
	check(k.swings == swings_before + 1, "presses during a swing are ignored (no buffering)")
	# Behind: enemy behind the King is never hit.
	await load_fresh()
	k = king()
	e = enemy()
	await place(Vector3(0, 0, 2), Vector3(0, 0, 3))
	await face(6)
	await tap("attack")
	await wait(30)
	check(e.health == 3, "enemy behind the King is not hit")
	# Out of reach: 1.6 m ahead.
	await place(Vector3(0, 0, 2), Vector3(0, 0, 0.4))
	await face(6)
	await tap("attack")
	await wait(30)
	check(e.health == 3, "enemy 1.6 m ahead (beyond 1.4 reach) is not hit")
	# Direction lock: turn right immediately after starting the swing; arc stays up.
	await place(Vector3(0, 0, 2), Vector3(0, 0, 1))
	await face(6)
	await tap("attack")
	hold_input(Vector2(1, 0))
	await wait(3)
	check(k.facing_index == 0 and k.attack_dir.is_equal_approx(Vector3(0, 0, -1)), "turning mid-swing changes facing but not the locked attack direction")
	hold_input(Vector2.ZERO)
	await wait(30)
	check(e.health == 2, "the locked arc still hits the enemy it was aimed at")
	# Locked direction also means a target moved to the new facing side is missed.
	await load_fresh()
	k = king()
	e = enemy()
	await place(Vector3(0, 0, 2), Vector3(-3, 0, 2))
	await face(6)
	await tap("attack")
	await wait(2)
	e.global_position = Vector3(1.0, 0, 2)
	await face(0)
	await wait(30)
	check(e.health == 3, "enemy placed in the new facing direction mid-swing is not hit")
	# Diagonal facing: up-right (index 7).
	var diag: Vector3 = Vector3(1, 0, -1).normalized()
	await place(Vector3(0, 0, 2), Vector3(0, 0, 2) + diag * 1.2)
	await face(7)
	await tap("attack")
	await wait(30)
	check(e.health == 2, "diagonal swing hits an enemy 1.2 m along the diagonal")
	await place(Vector3(0, 0, 2), Vector3(0, 0, 2) + Vector3(1.2, 0, 0.2))
	await face(5)
	await tap("attack")
	await wait(30)
	check(e.health == 2, "up-left swing misses an enemy to the right")
	# Arc edges with the real swing: 54 degrees off the facing hits, 57 misses.
	await load_fresh()
	k = king()
	e = enemy()
	var o: Vector3 = Vector3(0, 0, 2)
	await place(o, o + Vector3(sin(deg_to_rad(54.0)), 0, -cos(deg_to_rad(54.0))) * 1.3)
	await face(6)
	await tap("attack")
	await wait(30)
	check(e.health == 2, "real swing: enemy at 54 deg / 1.3 m is hit")
	await place(o, o + Vector3(sin(deg_to_rad(57.0)), 0, -cos(deg_to_rad(57.0))) * 1.3)
	await face(6)
	await tap("attack")
	await wait(30)
	check(e.health == 2, "real swing: enemy at 57 deg / 1.3 m is missed")
	await place(o, o + Vector3(0, 0, -1.38))
	await face(6)
	await tap("attack")
	await wait(30)
	check(e.health == 1, "real swing: enemy center at 1.38 m (inside reach) is hit")
	# Defeat at zero health; defeated enemy takes no more hits.
	await place(o, o + Vector3(0, 0, -1.0))
	await face(6)
	await tap("attack")
	await wait(30)
	check(e.health == 0 and not e.is_alive(), "third hit defeats the enemy")
	await tap("attack")
	await wait(30)
	check(e.health == 0, "a defeated enemy takes no further hits")
	# Visible arc matches the tested arc and timing.
	await load_fresh()
	k = king()
	var arc: MeshInstance3D = k.get_node("SwordArc")
	check(not arc.visible, "arc hidden while idle")
	await face(0)
	await tap("attack")
	check(arc.visible and is_equal_approx(arc.rotation.y, CombatSector.yaw_for(k.attack_dir)), "arc shown at swing start, rotated to the locked direction")
	await wait_until(func() -> bool: return k.attack_phase == 2, 10)
	var active_alpha: float = (arc.material_override as StandardMaterial3D).albedo_color.a
	await wait_until(func() -> bool: return k.attack_phase == 3, 20)
	check(active_alpha > 0.5 and not arc.visible, "arc bright while active, hidden in recovery")


func test_dodge() -> void:
	print("-- dodge movement, direction, hold, cooldown, collision")
	await load_fresh()
	var k: Variant = king()
	await place(Vector3(0, 0, 3), Vector3(-5, 0, -5))
	await face(0)
	var start: Vector3 = k.global_position
	await tap("dodge")
	check(k.dodging and k.dodge_dir.is_equal_approx(Vector3(1, 0, 0)), "neutral input dodges along the retained facing")
	await wait_until(func() -> bool: return not k.dodging, 30)
	var moved: float = flat(k.global_position - start).length()
	check(absf(moved - k.dodge_distance) < 0.08, "one dodge covers ~1.75 m once, not double (%.2f m)" % moved)
	await wait(5)
	check(flat(k.global_position - start).length() - moved < 0.01, "no slide after the dodge ends")
	# Analog input direction is used as-is (normalized), not snapped.
	await load_fresh()
	k = king()
	await place(Vector3(0, 0, 3), Vector3(-5, 0, -5))
	Input.action_press("move_right", 0.9)
	Input.action_press("move_down", 0.4)
	await tap("dodge")
	hold_input(Vector2.ZERO)
	check(k.dodge_dir.is_equal_approx(Vector3(0.9, 0, 0.4).normalized()), "dodge follows the current input direction")
	check(k.facing_index == 1, "facing snaps the same input (24 deg) to down-right (index %d)" % k.facing_index)
	# Holding dodge never repeats it.
	await load_fresh()
	k = king()
	Input.action_press("dodge")
	await wait(120)
	Input.action_release("dodge")
	check(k.dodges == 1, "holding dodge for 2 s gives exactly one dodge")
	# Cooldown runs from dodge start: 0.70 s.
	await load_fresh()
	k = king()
	await place(Vector3(0, 0, 3), Vector3(-5, 0, -5))
	check(k.try_dodge(Vector2.ZERO), "first dodge accepted")
	await wait(30)
	check(not k.try_dodge(Vector2.ZERO), "dodge at 0.50 s after start rejected (cooldown)")
	await wait(11)
	check(not k.try_dodge(Vector2.ZERO), "dodge at 0.683 s after start rejected")
	await wait(1)
	check(k.try_dodge(Vector2.ZERO), "dodge at 0.70 s after start accepted")
	# Walls stop a dodge.
	await load_fresh()
	k = king()
	await place(Vector3(5.0, 0, 0), Vector3(-5, 0, -5))
	await face(0)
	await tap("dodge")
	await wait(20)
	check(k.global_position.x < 5.6, "dodge into the east wall stops at the wall (x = %.2f)" % k.global_position.x)
	# A living enemy's body stops a dodge (solid collision).
	await load_fresh()
	k = king()
	await place(Vector3(0, 0, 2), Vector3(0, 0, 0.5))
	await face(6)
	await tap("dodge")
	await wait(20)
	check(k.global_position.z > 0.5 + 0.85, "dodge into the enemy stops at its body (z = %.2f)" % k.global_position.z)
	# No attack during a dodge; attack right after it ends.
	await load_fresh()
	k = king()
	await place(Vector3(0, 0, 3), Vector3(-5, 0, -5))
	k.try_dodge(Vector2.ZERO)
	await wait(2)
	check(not k.try_attack() and k.swings == 0, "attack is ignored during a dodge")
	await wait_until(func() -> bool: return not k.dodging, 20)
	check(k.try_attack(), "attack is available as soon as the dodge ends")


## King-side result of an enemy hit arriving `ticks` physics ticks after a dodge starts.
func iframe_result(ticks: int) -> int:
	await load_fresh()
	var k: Variant = king()
	await place(Vector3(0, 0, 3), Vector3(-5, 0, -5))
	k.try_dodge(Vector2.ZERO)
	await wait(ticks)
	return k.take_enemy_hit(1)


func test_iframes() -> void:
	print("-- invulnerability boundaries (0.04-0.16 s)")
	var hit: int = 0
	var dodged: int = 1
	check(await iframe_result(1) == hit, "0.017 s into dodge: hit")
	check(await iframe_result(2) == hit, "0.033 s into dodge: hit (before window)")
	check(await iframe_result(3) == dodged, "0.050 s into dodge: dodged")
	check(await iframe_result(6) == dodged, "0.100 s into dodge: dodged")
	check(await iframe_result(9) == dodged, "0.150 s into dodge: dodged")
	check(await iframe_result(10) == hit, "0.167 s into dodge: hit (after window)")
	check(await iframe_result(11) == hit, "0.183 s into dodge (still dodging): hit")
	var k: Variant = king()
	check(k.health == 2, "a hit removes 1 health")
	await wait(20)
	check(not k.is_invulnerable(), "no stale invulnerability after the dodge")
	# Player defeat.
	await load_fresh()
	k = king()
	k.take_enemy_hit(1)
	k.take_enemy_hit(1)
	check(not k.is_defeated, "2 hits: still standing")
	k.take_enemy_hit(1)
	check(k.is_defeated and k.health == 0, "3 hits: King defeated")
	check(k.take_enemy_hit(1) == 2 and k.health == 0, "hits after defeat are ignored")
	check(not k.try_attack() and not k.try_dodge(Vector2.ZERO), "defeated King cannot attack or dodge")


## Whether a dodge is accepted `ticks` ticks after a swing starts, and the King afterwards.
func cancel_at(ticks: int) -> bool:
	await load_fresh()
	var k: Variant = king()
	await place(Vector3(0, 0, 3), Vector3(-5, 0, -5))
	k.try_attack()
	await wait(ticks)
	return k.try_dodge(Vector2(1, 0))


func test_cancel() -> void:
	print("-- late-recovery dodge cancellation")
	check(not await cancel_at(2), "rejected in windup (0.033 s)")
	check(not await cancel_at(6), "rejected in active (0.100 s)")
	check(not await cancel_at(11), "rejected in active (0.183 s)")
	check(not await cancel_at(13), "rejected in early recovery (0.217 s, 0.183 s left)")
	check(not await cancel_at(17), "rejected in early recovery (0.283 s, 0.117 s left)")
	check(await cancel_at(18), "accepted in late recovery (0.300 s, 0.100 s left)")
	var k: Variant = king()
	var arc: MeshInstance3D = k.get_node("SwordArc")
	check(k.attack_phase == 0 and not arc.visible and k.cancels == 1 and k.dodging, "cancel ends the swing cleanly and starts the dodge")
	check(await cancel_at(22), "accepted in late recovery (0.367 s)")
	check(await cancel_at(30), "accepted when idle after the swing")
	# A cancelled swing cannot hit: enemy placed in its arc after cancel takes nothing.
	await load_fresh()
	k = king()
	var e: Variant = enemy()
	await place(Vector3(0, 0, 3), Vector3(-5, 0, -5))
	await face(6)
	k.try_attack()
	await wait(18)
	check(k.try_dodge(Vector2(1, 0)), "late-recovery cancel accepted")
	e.global_position = k.global_position + Vector3(0, 0, -1.0)
	await wait(30)
	check(e.health == 3, "cancelled swing never hits again (no prolonged hitbox)")
	# Real input path: Left Shift during late recovery cancels.
	await load_fresh()
	k = king()
	await place(Vector3(0, 0, 3), Vector3(-5, 0, -5))
	await tap("attack")
	await wait(16)
	var shift: InputEventKey = InputEventKey.new()
	shift.physical_keycode = KEY_SHIFT
	shift.keycode = KEY_SHIFT
	shift.location = KEY_LOCATION_LEFT
	shift.pressed = true
	Input.parse_input_event(shift)
	await wait(2)
	var release: InputEventKey = shift.duplicate()
	release.pressed = false
	Input.parse_input_event(release)
	check(k.dodging and k.cancels == 1, "Left Shift in late recovery cancels into a dodge")


func events_of(action: String) -> Array[String]:
	var out: Array[String] = []
	for ev: InputEvent in InputMap.action_get_events(action):
		if ev is InputEventKey:
			out.append("key:%d" % (ev as InputEventKey).physical_keycode)
		elif ev is InputEventJoypadButton:
			out.append("joy:%d" % (ev as InputEventJoypadButton).button_index)
		elif ev is InputEventJoypadMotion:
			out.append("axis:%d:%d" % [(ev as InputEventJoypadMotion).axis, signi(int((ev as InputEventJoypadMotion).axis_value))])
	return out


func test_input_isolation() -> void:
	print("-- input isolation")
	check(events_of("dodge") == ["key:%d" % KEY_SHIFT, "joy:%d" % JOY_BUTTON_B], "dodge = Left Shift + gamepad east (B)")
	var left_shift: InputEventKey = InputMap.action_get_events("dodge")[0]
	check(left_shift.location == KEY_LOCATION_LEFT, "dodge key is Left Shift specifically")
	check(events_of("attack") == ["key:%d" % KEY_J, "key:%d" % KEY_SPACE, "joy:%d" % JOY_BUTTON_X], "attack bindings unchanged (J, Space, west)")
	check(events_of("strike") == events_of("attack"), "strike bindings unchanged (same as attack)")
	check(events_of("interact") == ["key:%d" % KEY_E, "joy:%d" % JOY_BUTTON_A], "interact bindings unchanged")
	check(events_of("restart_test") == ["key:%d" % KEY_R, "joy:%d" % JOY_BUTTON_BACK], "restart_test bindings unchanged")
	check(events_of("move_left") == ["key:%d" % KEY_A, "key:%d" % KEY_LEFT, "axis:0:-1"], "move_left bindings unchanged")
	var overlaps: bool = false
	for ev: InputEvent in InputMap.action_get_events("dodge"):
		for ui: String in ["ui_accept", "ui_cancel", "ui_select"]:
			if InputMap.action_has_event(ui, ev):
				overlaps = true
	check(not overlaps, "dodge shares no event with ui_accept / ui_cancel / ui_select")
	# No P001-P006 code or test reads the new action.
	var files: Array[String] = []
	for dir_path: String in ["res://game/player", "res://game/prototypes", "res://game/prototypes/p002", "res://game/prototypes/p003", "res://game/prototypes/p004", "res://game/prototypes/p006", "res://tests"]:
		for f: String in DirAccess.get_files_at(dir_path):
			if f.ends_with(".gd") and not f.begins_with("p007"):
				files.append(dir_path + "/" + f)
	var readers: Array[String] = []
	for f: String in files:
		if FileAccess.get_file_as_string(f).contains("\"dodge\""):
			readers.append(f)
	check(files.size() >= 20 and readers.is_empty(), "no historical script reads the dodge action (%d files scanned)" % files.size())


const E_IDLE := 0
const E_APPROACH := 1
const E_WINDUP := 2
const E_STRIKE := 3
const E_RECOVERY := 4
const E_DEFEATED := 5
const O_NONE := 0
const O_HIT := 1
const O_DODGED := 2


## Fresh scene: enemy at the origin, King at `king_pos`, enemy released with no start delay.
## Returns once the enemy has begun its windup.
func prime_windup(king_pos: Vector3) -> void:
	await load_fresh()
	await place(king_pos, Vector3.ZERO)
	var e: Variant = enemy()
	e.start_delay = 0.0
	e.held = false
	await wait_until(func() -> bool: return e.state == E_WINDUP, 30)


## Keeps the King at `pos` (teleported before every tick) for `ticks` ticks.
func pin_king(pos: Vector3, ticks: int) -> void:
	for i in ticks:
		king().global_position = pos
		await physics_frame


func test_enemy_states() -> void:
	print("-- enemy approach, telegraph, commit, strike, recovery")
	await load_fresh()
	var k: Variant = king()
	var e: Variant = enemy()
	var seen: Array[int] = [e.state]
	var approach_start: Vector3 = e.global_position
	var approach_ticks: int = 0
	for i in 360:
		await physics_frame
		if e.state == E_APPROACH:
			approach_ticks += 1
		if e.state != seen[-1]:
			seen.append(e.state)
	check(seen.slice(0, 6) == [E_IDLE, E_APPROACH, E_WINDUP, E_STRIKE, E_RECOVERY, E_APPROACH], "state sequence: idle, approach, windup, strike, recovery, approach (%s)" % [seen])
	check(e.attacks_started >= 1 and e.attacks_completed >= 1, "attacks started (%d) and completed (%d) are counted" % [e.attacks_started, e.attacks_completed])
	# Approach speed is slower than the King's.
	await load_fresh()
	e = enemy()
	k = king()
	e.start_delay = 0.0
	await wait(2)
	var p0: Vector3 = e.global_position
	await wait(30)
	var speed: float = flat(e.global_position - p0).length() / 0.5
	check(e.state == E_APPROACH and absf(speed - 3.0) < 0.15 and speed < k.move_speed, "approach speed %.2f m/s is below the King's 5.0" % speed)
	# Stops at trigger range and starts the windup.
	await wait_until(func() -> bool: return e.state == E_WINDUP, 120)
	var gap: float = flat(k.global_position - e.global_position).length()
	check(gap <= e.attack_trigger_range + 0.06 and gap > 1.3, "windup starts at ~1.5 m (%.2f m)" % gap)
	# Before commit the aim follows the King; after commit it is locked.
	await prime_windup(Vector3(0, 0, 1.2))
	e = enemy()
	k = king()
	check(not e.committed and e.strike_dir.is_equal_approx(Vector3(0, 0, 1)), "windup aims at the King, not yet committed")
	var tele: MeshInstance3D = e.get_node("Telegraph")
	check(tele.visible and is_equal_approx(tele.rotation.y, CombatSector.yaw_for(e.strike_dir)), "telegraph visible and pointing along the strike direction")
	await pin_king(Vector3(1.2, 0, 0), 3)
	check(e.strike_dir.is_equal_approx(Vector3(1, 0, 0)), "before commit the aim tracks the King")
	await wait_until(func() -> bool: return e.committed, 30)
	var locked: Vector3 = e.strike_dir
	var faint_alpha: float = 0.16
	check((tele.material_override as StandardMaterial3D).albedo_color.a > faint_alpha, "telegraph turns solid at commit")
	check(e.state_time >= e.commit_time - TICK and e.state_time < e.commit_time + TICK * 1.5, "commit happens at ~0.25 s into the windup (%.3f s)" % e.state_time)
	# Circle the King around the enemy after commit: direction never changes.
	var changed: bool = false
	for i in 20:
		var angle: float = float(i) * 0.4
		k.global_position = Vector3(cos(angle), 0, sin(angle)) * 1.3
		await physics_frame
		if not e.strike_dir.is_equal_approx(locked):
			changed = true
		if e.state != E_WINDUP and e.state != E_STRIKE:
			break
	check(not changed, "committed strike direction stays fixed while the King circles")
	# Telegraph region equals the tested strike region.
	var verts: PackedVector3Array = (tele.mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var inside: bool = true
	for v: Vector3 in verts:
		if not CombatSector.contains(Vector3.ZERO, e.strike_dir, e.strike_reach, e.strike_arc_degrees, v.rotated(Vector3.UP, tele.rotation.y)):
			inside = false
	check(inside, "every telegraph vertex lies inside the tested strike sector")
	# Recovery: no movement, no telegraph, then approach again.
	await wait_until(func() -> bool: return e.state == E_RECOVERY, 60)
	var rp: Vector3 = e.global_position
	check(not tele.visible, "telegraph hidden in recovery")
	await wait(30)
	check(e.state == E_RECOVERY and flat(e.global_position - rp).length() < 0.001, "enemy stands still through recovery")
	await wait_until(func() -> bool: return e.state != E_RECOVERY, 40)
	check(e.state == E_APPROACH or e.state == E_WINDUP, "recovery ends after ~0.6 s")


func test_strike_resolution() -> void:
	print("-- first-contact strike resolution (Amendment A1)")
	var inside: Vector3 = Vector3(0, 0, 1.0)
	var outside: Vector3 = Vector3(0, 0, 3.0)
	# (a) First contact during i-frames: dodged; staying in the zone after i-frames end does no harm.
	await prime_windup(Vector3(0, 0, 1.2))
	var k: Variant = king()
	var e: Variant = enemy()
	await wait_until(func() -> bool: return e.state_time >= e.windup - 4.5 * TICK, 40)
	check(k.try_dodge(Vector2(0, 1)), "(a) dodge started just before the strike")
	var invuln_at_contact: bool = false
	var after_iframes_in_zone: int = 0
	for i in 14:
		k.global_position = inside
		await physics_frame
		if e.state == E_STRIKE and e.strike_outcome == O_DODGED and not invuln_at_contact:
			invuln_at_contact = true
		if e.state == E_STRIKE and not k.is_invulnerable() and invuln_at_contact:
			after_iframes_in_zone += 1
	check(invuln_at_contact and e.dodges_confirmed == 1, "(a) first contact during invulnerability = confirmed dodge")
	check(after_iframes_in_zone >= 1, "(a) King stayed in the active zone after invulnerability ended (%d ticks)" % after_iframes_in_zone)
	await wait_until(func() -> bool: return e.state == E_RECOVERY, 20)
	check(k.health == 3 and e.hits_landed == 0 and e.dodges_confirmed == 1, "(a) the dodged strike never becomes damage; one dodge recorded")
	# (b) No dodge, King inside for the whole strike: exactly one hit.
	await prime_windup(Vector3(0, 0, 1.2))
	k = king()
	e = enemy()
	await wait_until(func() -> bool: return e.state == E_STRIKE, 40)
	await pin_king(inside, 12)
	check(k.health == 2 and e.hits_landed == 1 and e.strike_outcome == O_HIT, "(b) King inside for the whole strike takes exactly 1 hit")
	# (f) Next strike starts unresolved; King outside: no hit.
	await wait_until(func() -> bool: return e.state == E_WINDUP, 120)
	await wait_until(func() -> bool: return e.committed, 30)
	await pin_king(outside, 1)
	await wait_until(func() -> bool: return e.state == E_STRIKE, 40)
	check(e.strike_outcome == O_NONE, "(f) the next strike begins with a fresh, unresolved state")
	await pin_king(outside, 12)
	check(k.health == 2 and e.attacks_completed == 2, "(e) a strike that never touches the King does no damage")
	# (c) First contact before i-frames: hit; later invulnerability cannot convert it.
	await prime_windup(Vector3(0, 0, 1.2))
	k = king()
	e = enemy()
	await wait_until(func() -> bool: return e.state == E_STRIKE, 40)
	check(e.strike_outcome == O_HIT and k.health == 2, "(c) first contact outside invulnerability hits")
	k.try_dodge(Vector2(0, 1))
	await pin_king(inside, 10)
	check(e.strike_outcome == O_HIT and e.dodges_confirmed == 0 and k.health == 2, "(c) dodging after the hit adds no dodge and no second hit")
	# (d) Contact after i-frames have ended: hit.
	await prime_windup(Vector3(0, 0, 1.2))
	k = king()
	e = enemy()
	await wait_until(func() -> bool: return e.committed, 30)
	k.global_position = outside
	await wait_until(func() -> bool: return e.state_time >= e.windup - 13.5 * TICK, 40)
	k.try_dodge(Vector2(1, 0))
	await wait_until(func() -> bool: return e.state == E_STRIKE, 40)
	await pin_king(outside, 1)
	check(not k.is_invulnerable() and e.strike_outcome == O_NONE, "(d) strike active, King outside and no longer invulnerable")
	await pin_king(inside, 3)
	check(e.strike_outcome == O_HIT and k.health == 2, "(d) entering the zone after invulnerability ended is a hit")


func test_enemy_limits() -> void:
	print("-- no contact damage, enemy defeat, player defeat")
	# Damage only ever happens during STRIKE; pushing into the enemy otherwise does nothing.
	await load_fresh()
	var k: Variant = king()
	var e: Variant = enemy()
	var bad: Array[int] = []
	k.damaged.connect(func() -> void:
		if e.state != E_STRIKE:
			bad.append(e.state))
	await place(Vector3(0, 0, 0.5), Vector3.ZERO)
	hold_input(Vector2(0, -1))
	await wait(90)
	check(k.health == 3, "held enemy: King pressing into its body for 1.5 s takes no damage")
	e.held = false
	e.start_delay = 0.0
	await wait(300)
	hold_input(Vector2.ZERO)
	check(k.health < 3 and bad.is_empty(), "King took %d hit(s), every one during a strike (other states seen: %s)" % [3 - k.health, bad])
	# Enemy defeated mid-windup: no strike, no further damage.
	await prime_windup(Vector3(0, 0, 1.2))
	k = king()
	e = enemy()
	e.health = 1
	await face(6)
	k.global_position = Vector3(0, 0, 1.2)
	await tap("attack")
	await wait(10)
	check(e.state == E_DEFEATED and not e.get_node("Telegraph").visible, "enemy killed in windup is defeated and its telegraph is gone")
	var pos: Vector3 = e.global_position
	await pin_king(Vector3(0, 0, 1.0), 180)
	check(k.health == 3 and e.global_position.is_equal_approx(pos) and e.state == E_DEFEATED, "defeated enemy never strikes or moves again")
	check(e.get_node("CollisionShape3D").disabled, "defeated enemy no longer blocks the King")
	# Player defeat: enemy stops attacking.
	await prime_windup(Vector3(0, 0, 1.2))
	k = king()
	e = enemy()
	k.health = 1
	await pin_king(Vector3(0, 0, 1.2), 40)
	check(k.is_defeated, "third hit (health 1 -> 0) defeats the King")
	var started: int = e.attacks_started
	await wait(240)
	check(e.state == E_IDLE and e.attacks_started == started, "enemy stops attacking once the King is defeated")


func press_key(code: Key) -> void:
	var ev: InputEventKey = InputEventKey.new()
	ev.physical_keycode = code
	ev.keycode = code
	ev.pressed = true
	Input.parse_input_event(ev)
	await process_frame
	var up: InputEventKey = ev.duplicate()
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame


## Presses R (restart_test) and waits for the reloaded scene.
func retry_with_key() -> bool:
	var old_id: int = current_scene.get_instance_id()
	await press_key(KEY_R)
	for i in 30:
		await process_frame
		if current_scene != null and current_scene.get_instance_id() != old_id and current_scene.is_node_ready():
			await physics_frame
			return true
	return false


func check_fresh(label: String) -> void:
	var root: Node = scene()
	var k: Variant = king()
	var e: Variant = enemy()
	var enemies: int = root.find_children("TrainingEnemy*", "CharacterBody3D", true, false).size()
	var ok: bool = enemies == 1 and k.health == 3 and not k.is_defeated and e.health == 3 and e.state == E_IDLE
	ok = ok and flat(k.global_position).distance_to(Vector2(0, 3)) < 0.05 and flat(e.global_position).distance_to(Vector2(0, -3)) < 0.05
	ok = ok and k.attack_phase == 0 and not k.dodging and not k.is_invulnerable() and k.dodge_cooldown_left == 0.0
	ok = ok and k.facing_index == 6 and k.swings == 0 and k.dodges == 0 and e.attacks_started == 0 and not e.held
	ok = ok and root.result == "" and root.hits_dealt == 0 and root.hits_taken == 0
	check(ok, "%s: retry restores health, positions, facing, cooldowns, phases, counters; one enemy" % label)


func test_encounter_and_retry() -> void:
	print("-- encounter result, HUD, diagnostics, retry")
	await load_fresh()
	var root: Node = scene()
	var k: Variant = king()
	var e: Variant = enemy()
	var hud: Label = root.get_node("HUD/HealthLabel")
	check(hud.text == "King ♥♥♥     Enemy ●●●", "HUD shows full health")
	# Win: three hits from the King.
	await place(Vector3(0, 0, 2), Vector3(0, 0, 1))
	await face(6)
	for i in 3:
		await tap("attack")
		await wait(26)
	check(root.result == "victory" and e.state == E_DEFEATED, "three sword hits win the encounter")
	check(root.hits_dealt == 3 and root.result_line.contains("| victory |") and root.result_line.contains("hits dealt 3"), "result line records the win and all 3 hits (killing hit included)")
	check(hud.text == "King ♥♥♥     Enemy ○○○", "HUD shows the enemy at 0")
	check(root.find_children("*", "Label3D", false, false).size() >= 1, "hit feedback popup spawned")
	# Dodge in late recovery and leftover cooldown before retrying, to prove the reset.
	k.try_attack()
	await wait(18)
	k.try_dodge(Vector2(1, 0))
	await wait(2)
	check(k.dodging and k.dodge_cooldown_left > 0.0, "mid-dodge with cooldown running before retry")
	check(await retry_with_key(), "R reloads the encounter after a win")
	check_fresh("after win")
	# Loss.
	k = king()
	e = enemy()
	root = scene()
	await prime_windup(Vector3(0, 0, 1.2))
	root = scene()
	k = king()
	e = enemy()
	k.health = 1
	root._update_health()
	await pin_king(Vector3(0, 0, 1.2), 40)
	check(root.result == "defeat" and root.result_line.contains("| defeat |"), "losing all health ends the encounter as a defeat")
	check((root.get_node("HUD/PromptLabel") as Label).text.contains("Retry"), "win/loss prompt shows the retry key")
	var finished_line: String = root.result_line
	await wait(30)
	check(root.result_line == finished_line, "the result is recorded once per attempt")
	check(await retry_with_key(), "R reloads the encounter after a loss")
	check_fresh("after loss")
	# Retry mid-fight (enemy winding up, King mid-swing) is also clean.
	root = scene()
	enemy().start_delay = 0.0
	king().global_position = Vector3(0, 0, -1.4)
	await wait_until(func() -> bool: return enemy().state == E_WINDUP, 60)
	king().try_attack()
	await wait(3)
	check(await retry_with_key(), "R reloads mid-fight")
	check_fresh("mid-fight")
	# Developer keys.
	root = scene()
	var dbg: Label = root.get_node("HUD/DebugLabel")
	check(not dbg.visible, "diagnostics hidden by default")
	await press_key(KEY_F3)
	await process_frame
	check(dbg.visible and dbg.text.contains("King: sword") and dbg.text.contains("Enemy:"), "F3 shows the diagnostics panel")
	await press_key(KEY_F3)
	check(not dbg.visible, "F3 hides it again")
	await press_key(KEY_F4)
	check(enemy().held, "F4 holds the enemy")
	var held_pos: Vector3 = enemy().global_position
	await wait(120)
	check(enemy().state == E_IDLE and enemy().global_position.is_equal_approx(held_pos), "held enemy does not act")
	await press_key(KEY_F4)
	check(not enemy().held, "F4 releases it")


# --- Iteration 1: target focus (Mode B) ---

## Fresh scene in Mode B, King and held enemy placed, focus pressed. Returns whether it focused.
func focus_setup(king_pos: Vector3, enemy_pos: Vector3) -> bool:
	await load_fresh()
	king().focus_available = true
	await place(king_pos, enemy_pos)
	await tap("target_focus")
	return king().focused


## Expected focused facing: the existing eight-direction snap of the bearing to the enemy.
func snapped_bearing_index() -> int:
	return king().snap_index(flat(enemy().global_position - king().global_position))


func releases(reason: String) -> int:
	return int(king().focus_releases[reason])


func release_total() -> int:
	var total: int = 0
	for n: int in king().focus_releases.values():
		total += n
	return total


func tab_event(pressed: bool, echo: bool) -> InputEventKey:
	var ev: InputEventKey = InputEventKey.new()
	ev.physical_keycode = KEY_TAB
	ev.keycode = KEY_TAB
	ev.pressed = pressed
	ev.echo = echo
	return ev


func test_focus_acquisition() -> void:
	print("-- focus acquisition (Mode B), Mode A ignores focus")
	await load_fresh()
	var k: Variant = king()
	check(not k.focus_available and not k.focused, "a fresh encounter starts in Mode A, unfocused")
	await place(Vector3(0, 0, 3), Vector3(0, 0, -1))
	await face(0)
	await tap("target_focus")
	check(not k.focused and k.focus_acquisitions == 0 and k.facing_index == 0, "Mode A: focus press does nothing (facing stays movement-based)")
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, -3)), "Mode B: acquires the living enemy at 6.0 m")
	k = king()
	check(k.focus_target == enemy() and k.focus_acquisitions == 1, "focus target is the Training Enemy")
	await tap("target_focus")
	check(not k.focused and k.focus_target == null and releases("press") == 1, "second press releases (reason: press)")
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, -4)), "acquires at exactly 7.0 m (inclusive)")
	check(not await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, -4.1)), "rejects at 7.1 m")
	k = king()
	check(k.focus_acquisitions == 0 and release_total() == 0 and k.facing_index == 6, "failed acquisition changes nothing")
	# Defeated enemy.
	await load_fresh()
	k = king()
	k.focus_available = true
	await place(Vector3(0, 0, 3), Vector3(0, 0, 1))
	for i in 3:
		enemy().take_sword_hit()
	await tap("target_focus")
	check(not enemy().is_alive() and not k.focused, "a defeated enemy cannot be focused")
	# Removed enemy.
	await load_fresh()
	k = king()
	k.focus_available = true
	await place(Vector3(0, 0, 3), Vector3(0, 0, 1))
	enemy().free()
	await tap("target_focus")
	check(not k.focused and k.focus_acquisitions == 0, "a removed enemy cannot be focused (no error)")
	# Holding the button toggles once.
	await load_fresh()
	k = king()
	k.focus_available = true
	await place(Vector3(0, 0, 3), Vector3(0, 0, -1))
	Input.action_press("target_focus")
	await wait(60)
	Input.action_release("target_focus")
	await wait(2)
	check(k.focused and k.focus_acquisitions == 1 and release_total() == 0, "holding focus for 1 s toggles exactly once")
	# Real Tab key path, and key-repeat echo does not toggle.
	await load_fresh()
	k = king()
	k.focus_available = true
	await place(Vector3(0, 0, 3), Vector3(0, 0, -1))
	Input.parse_input_event(tab_event(true, false))
	await wait(2)
	check(k.focused, "the Tab key focuses (ui_focus_next overlap does not block it)")
	for i in 3:
		Input.parse_input_event(tab_event(true, true))
		await wait(2)
	Input.parse_input_event(tab_event(false, false))
	await wait(2)
	check(k.focused and k.focus_acquisitions == 1 and release_total() == 0, "Tab key-repeat echoes do not toggle focus")


func test_focus_lifecycle() -> void:
	print("-- focus release: defeat, removal, range hysteresis, King defeat")
	# Defeating hit releases focus on the same tick.
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, 2)), "focused at 1.0 m")
	var k: Variant = king()
	var e: Variant = enemy()
	e.take_sword_hit()
	e.take_sword_hit()
	k.try_attack()
	await wait_until(func() -> bool: return not e.is_alive(), 20)
	check(not e.is_alive() and not k.focused and releases("defeat") == 1, "focus releases on the tick the enemy is defeated (reason: defeat)")
	await tap("target_focus")
	check(not k.focused, "cannot re-focus the defeated enemy")
	# Removed enemy releases (no error).
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, 0)), "focused at 3.0 m")
	k = king()
	enemy().queue_free()
	await wait(3)
	check(not k.focused and k.focus_target == null and releases("invalid") == 1, "focus releases when the enemy is removed (reason: invalid)")
	# Range: 9.0 m release, with no flicker inside the 7-9 m band.
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, -3)), "focused at 6.0 m")
	k = king()
	e = enemy()
	e.global_position = Vector3(0, 0, -5.9)
	await wait(3)
	check(k.focused, "still focused at 8.9 m (beyond the 7.0 m acquire range)")
	for i in 120:
		e.global_position = Vector3(0, 0, -5.5 if i % 2 == 0 else -6.0)
		await physics_frame
	check(k.focused and release_total() == 0, "120 ticks alternating 8.5 / 9.0 m: no release")
	e.global_position = Vector3(0, 0, -6.1)
	await wait(2)
	check(not k.focused and releases("range") == 1, "releases beyond 9.0 m (9.1 m, reason: range)")
	e.global_position = Vector3(0, 0, -5.0)
	await wait(1)
	await tap("target_focus")
	check(not k.focused, "re-acquire rejected at 8.0 m")
	e.global_position = Vector3(0, 0, -4.0)
	await wait(1)
	await tap("target_focus")
	check(k.focused and k.focus_acquisitions == 2, "re-acquired at 7.0 m")
	# King defeat releases.
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, -1)), "focused at 4.0 m")
	k = king()
	for i in 3:
		k.take_enemy_hit(1)
	check(k.is_defeated and not k.focused and releases("king_defeated") == 1, "King defeat releases focus")
	check(not k.toggle_focus() and not k.focused, "a defeated King cannot focus")
	await load_fresh()
	check(not king().focused, "a new encounter starts unfocused")


func test_focus_facing() -> void:
	print("-- focused facing: eight-direction snap toward the enemy; movement unchanged")
	# Mode B but unfocused: movement-based facing exactly as Mode A.
	await load_fresh()
	var k: Variant = king()
	k.focus_available = true
	await place(Vector3(0, 0, 3), Vector3(0, 0, -1))
	await face(0)
	check(k.facing_index == 0 and not k.focused, "Mode B unfocused: facing follows movement")
	# Walking distance is unchanged by focus: same input, same displacement as Mode A.
	await load_fresh()
	await place(Vector3(0, 0, 0), Vector3(0, 0, -3))
	var start_a: Vector3 = king().global_position
	hold_input(Vector2(0, 1))
	await wait(30)
	hold_input(Vector2.ZERO)
	var walked_a: Vector3 = king().global_position - start_a
	check(king().facing_index == 2, "Mode A: walking away turns the King away (down)")
	check(await focus_setup(Vector3(0, 0, 0), Vector3(0, 0, -3)), "Mode B focused at 3.0 m")
	k = king()
	var start_b: Vector3 = k.global_position
	hold_input(Vector2(0, 1))
	await wait(30)
	hold_input(Vector2.ZERO)
	var walked_b: Vector3 = k.global_position - start_b
	check(walked_b.distance_to(walked_a) < 0.001, "focused retreat moves exactly as far as Mode A (%.3f vs %.3f m)" % [walked_b.length(), walked_a.length()])
	check(k.facing_index == 6 and k.facing_dir.is_equal_approx(k.direction_for_index(6)), "focused retreat keeps facing the enemy (up)")
	# Strafing: facing follows the snapped bearing every tick and changes as the bearing crosses 22.5 deg.
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, -1)), "focused at 4.0 m")
	k = king()
	hold_input(Vector2(1, 0))
	var always_snapped: bool = true
	var seen: Dictionary = {}
	for i in 45:
		await physics_frame
		await physics_frame
		# Facing is set at the start of the King's tick, before he moves: compare one tick later.
		seen[k.facing_index] = true
		if not k.facing_dir.is_equal_approx(k.direction_for_index(k.facing_index)):
			always_snapped = false
	hold_input(Vector2.ZERO)
	await wait(2)
	check(always_snapped and k.facing_index == snapped_bearing_index(), "strafing: facing is always one of the eight snapped directions toward the enemy")
	check(seen.has(6) and seen.has(5) and not seen.has(0), "strafing right turns the facing up -> up-left, never toward the movement")
	# Tracking a moving enemy, including near a 22.5-degree boundary.
	var spots: Array[Vector3] = [Vector3(2, 0, 0), Vector3(0, 0, 2), Vector3(-2, 0, -2), Vector3(-2, 0, 0)]
	var expected: Array[int] = [0, 2, 5, 4]
	var tracked: bool = true
	for i in spots.size():
		enemy().global_position = k.global_position + spots[i]
		await wait(2)
		if k.facing_index != expected[i]:
			tracked = false
	check(tracked, "facing tracks the enemy to right / down / up-left / left")
	enemy().global_position = k.global_position + Vector3(sin(deg_to_rad(20.0)), 0, -cos(deg_to_rad(20.0))) * 3.0
	await wait(2)
	check(k.facing_index == 6 and k.facing_dir.is_equal_approx(Vector3(0, 0, -1)), "enemy 20 deg right of up: facing snaps to exactly up (no continuous aim)")
	enemy().global_position = k.global_position + Vector3(sin(deg_to_rad(25.0)), 0, -cos(deg_to_rad(25.0))) * 3.0
	await wait(2)
	check(k.facing_index == 7, "enemy 25 deg right of up: facing snaps to up-right")
	# Sprite flip follows the target, not the movement.
	enemy().global_position = k.global_position + Vector3(-2, 0, 0)
	await wait(2)
	hold_input(Vector2(1, 0))
	await wait(10)
	hold_input(Vector2.ZERO)
	await wait(2)
	var visual: Sprite3D = k.get_node("Visual")
	check(visual.flip_h, "moving right with the enemy to the left: sprite faces left (target)")
	enemy().global_position = k.global_position + Vector3(0, 0, -2)
	await wait(2)
	check(visual.flip_h and k.facing_index == 6, "enemy straight up: last flip kept")
	# Release: facing kept until movement input changes it, then movement-based again.
	await tap("target_focus")
	check(not k.focused and k.facing_index == 6, "after release with no input, the last facing is kept")
	await face(0)
	check(k.facing_index == 0 and not visual.flip_h, "after release, movement input turns the King again (right)")


func test_focus_sword() -> void:
	print("-- focused sword: snapshot at start, no tracking, same reach and arc, no auto-approach")
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, 2)), "focused at 1.0 m")
	var k: Variant = king()
	var e: Variant = enemy()
	check(is_equal_approx(k.sword_reach, 1.4) and is_equal_approx(k.sword_arc_degrees, 110.0), "sword reach and arc unchanged in Mode B (1.4 m, 110 deg)")
	var arc: MeshInstance3D = k.get_node("SwordArc")
	k.try_attack()
	check(k.attack_dir.is_equal_approx(k.direction_for_index(6)) and is_equal_approx(arc.rotation.y, CombatSector.yaw_for(k.attack_dir)), "swing snapshots the focused facing (up); arc drawn along it")
	await wait(1)
	e.global_position = k.global_position + Vector3(1.0, 0, 0)
	await wait(20)
	check(k.attack_dir.is_equal_approx(k.direction_for_index(6)) and e.health == 3, "enemy moved 90 deg aside mid-swing: swing does not follow it (no hit)")
	check(k.facing_index == 0, "facing itself keeps tracking (right) for the next swing")
	# Reach unchanged: dead centre at 1.5 m misses, 1.3 m hits.
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, 1.5)), "focused, enemy dead centre at 1.5 m")
	k = king()
	k.try_attack()
	await wait(25)
	check(enemy().health == 3, "beyond the 1.4 m reach: no hit even when focused")
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, 1.7)), "focused, enemy dead centre at 1.3 m")
	k = king()
	k.try_attack()
	await wait(25)
	check(enemy().health == 2 and k.sword_hits == 1, "inside reach: exactly one hit")
	# Snapped, not continuous: the swing goes along the snapped direction.
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, 3) + Vector3(sin(deg_to_rad(20.0)), 0, -cos(deg_to_rad(20.0))) * 1.2), "focused, enemy 20 deg off up at 1.2 m")
	k = king()
	k.try_attack()
	check(k.attack_dir.is_equal_approx(Vector3(0, 0, -1)), "swing direction is the snapped facing (up), not the exact bearing")
	await wait(25)
	check(enemy().health == 2, "20 deg off the snapped direction is inside the 55 deg half-arc: hit")
	# No automatic movement toward the target.
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, 0)), "focused at 3.0 m, no input")
	k = king()
	var still: Vector3 = k.global_position
	k.try_attack()
	await wait(60)
	check(k.global_position.distance_to(still) < 0.001, "focus never moves the King toward the target")
	# Retreat-and-attack: focused hits while backing away; Mode A turns away and misses.
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, 2.1)), "focused at 0.9 m")
	k = king()
	hold_input(Vector2(0, 1))
	await tap("attack")
	await wait(20)
	hold_input(Vector2.ZERO)
	check(enemy().health == 2 and k.retreat_swings == 1 and k.retreat_hits == 1, "focused: attack while retreating hits the enemy")
	await load_fresh()
	k = king()
	await place(Vector3(0, 0, 3), Vector3(0, 0, 2.1))
	await face(6)
	hold_input(Vector2(0, 1))
	await tap("attack")
	await wait(20)
	hold_input(Vector2.ZERO)
	check(enemy().health == 3 and k.attack_dir.is_equal_approx(k.direction_for_index(2)) and k.retreat_swings == 1 and k.retreat_hits == 0, "Mode A: the same retreat turns the swing away (down) and misses")


## Focused variants of the King-side invulnerability and cancel timing checks.
func focused_iframe_result(ticks: int) -> int:
	await focus_setup(Vector3(0, 0, 3), Vector3(-3, 0, -1))
	var k: Variant = king()
	k.try_dodge(Vector2.ZERO)
	await wait(ticks)
	return k.take_enemy_hit(1)


func focused_cancel_at(ticks: int) -> bool:
	await focus_setup(Vector3(0, 0, 3), Vector3(-3, 0, -1))
	var k: Variant = king()
	k.try_attack()
	await wait(ticks)
	return k.try_dodge(Vector2(1, 0))


func test_focus_dodge() -> void:
	print("-- focused dodge: input direction, neutral along facing, persistence, timing unchanged")
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, -1)), "focused at 4.0 m")
	var k: Variant = king()
	var start: Vector3 = k.global_position
	hold_input(Vector2(1, 0))
	await tap("dodge")
	hold_input(Vector2.ZERO)
	check(k.dodging and k.dodge_dir.is_equal_approx(Vector3(1, 0, 0)), "focused: dodge follows the movement input (right), not the target")
	check(k.focused, "focus stays on during the dodge")
	await wait_until(func() -> bool: return not k.dodging, 30)
	var moved: Vector3 = k.global_position - start
	check(absf(moved.x - k.dodge_distance) < 0.08 and absf(moved.z) < 0.01, "focused dodge covers ~1.75 m to the right (%.2f m)" % moved.x)
	# Facing is set at the start of each tick, before that tick's move: one tick later it reflects
	# where the dodge ended (here the bearing sits just past the 22.5 deg boundary).
	await wait(1)
	check(k.focused and k.facing_index == snapped_bearing_index(), "after the dodge: still focused, facing the enemy's snapped bearing")
	# Neutral focused dodge follows the current facing, i.e. toward the enemy (Amendment B).
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, -1)), "focused at 4.0 m, neutral input")
	k = king()
	start = k.global_position
	await tap("dodge")
	check(k.dodge_dir.is_equal_approx(k.facing_dir) and k.dodge_dir.is_equal_approx(Vector3(0, 0, -1)), "neutral focused dodge goes along the current facing (toward the enemy)")
	await wait_until(func() -> bool: return not k.dodging, 30)
	check(absf((start - k.global_position).z - k.dodge_distance) < 0.08, "open space: the full 1.75 m toward the enemy")
	check(await focus_setup(Vector3(0, 0, 2), Vector3(0, 0, 0.5)), "focused at 1.5 m, neutral input")
	k = king()
	await tap("dodge")
	await wait(20)
	var gap: float = flat(enemy().global_position - k.global_position).length()
	check(k.global_position.z > 0.5 + 0.85 and gap > 0.85, "neutral focused dodge into the enemy stops at its body, no overlap (gap %.2f m)" % gap)
	# The first attack after a dodge uses the bearing from where the dodge ended.
	check(await focus_setup(Vector3(0, 0, 3), Vector3(0, 0, 1)), "focused at 2.0 m")
	k = king()
	hold_input(Vector2(1, 0))
	await tap("dodge")
	hold_input(Vector2.ZERO)
	await wait_until(func() -> bool: return not k.dodging, 30)
	await tap("attack")
	check(k.focused and k.facing_index == 5 and k.attack_dir.is_equal_approx(k.direction_for_index(5)), "attack right after a sideways dodge swings at the enemy (up-left)")
	# Timing tables repeated while focused: identical to the unfocused results.
	var hit: int = 0
	var dodged: int = 1
	var iframes_ok: bool = true
	for t: int in [1, 2, 10, 11]:
		if await focused_iframe_result(t) != hit:
			iframes_ok = false
	for t: int in [3, 6, 9]:
		if await focused_iframe_result(t) != dodged:
			iframes_ok = false
	check(iframes_ok and king().focused, "focused: invulnerability window unchanged (ticks 3-9 dodged; 1, 2, 10, 11 hit)")
	var cancel_ok: bool = true
	for t: int in [2, 6, 11, 13, 17]:
		if await focused_cancel_at(t):
			cancel_ok = false
	for t: int in [18, 22, 30]:
		if not await focused_cancel_at(t):
			cancel_ok = false
	check(cancel_ok, "focused: late-recovery cancel window unchanged (ticks 18+ accepted, 2-17 rejected)")
	check(await focus_setup(Vector3(0, 0, 3), Vector3(-3, 0, -1)), "focused")
	k = king()
	check(k.try_dodge(Vector2(1, 0)), "focused: first dodge accepted")
	await wait(41)
	check(not k.try_dodge(Vector2(1, 0)), "focused: cooldown still blocks at 0.683 s")
	await wait(1)
	check(k.try_dodge(Vector2(1, 0)), "focused: dodge accepted at 0.70 s")


## Presses F2 (mode switch) and waits for the reloaded scene.
func switch_mode_with_key() -> bool:
	var old_id: int = current_scene.get_instance_id()
	await press_key(KEY_F2)
	for i in 30:
		await process_frame
		if current_scene != null and current_scene.get_instance_id() != old_id and current_scene.is_node_ready():
			await physics_frame
			return true
	return false


func test_focus_inputs() -> void:
	print("-- target_focus input isolation")
	check(events_of("target_focus") == ["key:%d" % KEY_TAB, "joy:%d" % JOY_BUTTON_RIGHT_SHOULDER], "target_focus = Tab + gamepad RB")
	var overlaps: bool = false
	for ev: InputEvent in InputMap.action_get_events("target_focus"):
		for action: String in ["ui_accept", "ui_cancel", "ui_select", "attack", "strike", "dodge", "interact", "restart_test"]:
			if InputMap.action_has_event(action, ev):
				overlaps = true
	check(not overlaps, "target_focus shares no event with UI confirm/cancel or any gameplay action")
	await load_fresh()
	var focusable: Array[String] = []
	for c: Node in scene().find_children("*", "Control", true, false):
		if (c as Control).focus_mode != Control.FOCUS_NONE:
			focusable.append(String(c.name))
	check(focusable.is_empty(), "no focusable Control in the P007 scene, so Tab (also ui_focus_next) moves no GUI focus")
	var files: Array[String] = []
	for dir_path: String in ["res://game/player", "res://game/prototypes", "res://game/prototypes/p002", "res://game/prototypes/p003", "res://game/prototypes/p004", "res://game/prototypes/p006", "res://tests"]:
		for f: String in DirAccess.get_files_at(dir_path):
			if f.ends_with(".gd") and not f.begins_with("p007"):
				files.append(dir_path + "/" + f)
	var readers: Array[String] = []
	for f: String in files:
		if FileAccess.get_file_as_string(f).contains("target_focus") or FileAccess.get_file_as_string(f).contains("p007_control_mode"):
			readers.append(f)
	check(files.size() >= 20 and readers.is_empty(), "no historical script reads target_focus or the P007 mode (%d files scanned)" % files.size())


func test_focus_mode_and_logging() -> void:
	print("-- A/B mode switch, focus marker and HUD, comparison logging")
	root.remove_meta(&"p007_control_mode")
	await load_fresh()
	var mode_label: Label = scene().get_node("HUD/ModeLabel")
	var marker: Label3D = scene().get_node("FocusMarker")
	check(scene().control_mode == "A" and not king().focus_available and not root.has_meta(&"p007_control_mode"), "the experiment starts in Mode A")
	check(mode_label.text.begins_with("Mode A") and not marker.visible, "HUD shows Mode A; no focus marker")
	# F2 mid-fight: switches to Mode B and restarts the attempt.
	enemy().take_sword_hit()
	king().take_enemy_hit(1)
	check(await switch_mode_with_key(), "F2 reloads the encounter")
	check(scene().control_mode == "B" and king().focus_available and not king().focused, "F2 switched to Mode B; the new attempt starts unfocused")
	check_fresh("after F2")
	mode_label = scene().get_node("HUD/ModeLabel")
	marker = scene().get_node("FocusMarker")
	check(mode_label.text.begins_with("Mode B") and mode_label.text.contains("focus off") and not marker.visible, "HUD shows Mode B with focus off")
	# Scripted Mode B attempt with known focused / unfocused activity.
	var root_node: Node = scene()
	var k: Variant = king()
	var e: Variant = enemy()
	await place(Vector3(0, 0, 2), Vector3(0, 0, 1))
	await face(6)
	await tap("attack")
	await wait(26)
	await tap("target_focus")
	await process_frame
	check(k.focused and mode_label.text.contains("FOCUS ON") and marker.visible, "focused: HUD says FOCUS ON and the marker is shown")
	check(marker.global_position.distance_to(e.global_position + Vector3(0, 2.35, 0)) < 0.01, "marker sits above the focused enemy")
	await tap("attack")
	await wait(26)
	check(k.try_dodge(Vector2(1, 0)), "focused dodge")
	await wait(20)
	k.take_enemy_hit(1)
	await tap("target_focus")
	check(not k.focused and not marker.visible and mode_label.text.contains("focus off"), "release hides the marker at once")
	await wait(30)
	check(k.try_dodge(Vector2(-1, 0)), "unfocused dodge")
	await wait(20)
	k.take_enemy_hit(1)
	await place(Vector3(0, 0, 2), Vector3(0, 0, 1))
	await tap("target_focus")
	await tap("attack")
	await wait(26)
	await process_frame
	check(root_node.result == "victory" and not k.focused and not marker.visible, "victory while focused: focus released, marker hidden")
	var line: String = root_node.result_line
	print("INFO  ", line)
	check(line.contains("| controls B |"), "result line records Mode B")
	check(line.contains("focus acquired 2, released: press 1, range 0, defeat 1, invalid 0, king defeated 0"), "result line counts acquisitions and releases by reason")
	check(line.contains("swings 2/1") and line.contains("sword hits 2/1") and line.contains("dodges 1/1") and line.contains("damage taken 1/1"), "result line splits focused/unfocused swings, hits, dodges, damage")
	check(k.swings == 3 and root_node.hits_dealt == k.sword_hits and k.sword_hits == 3 and root_node.hits_taken == k.hits_taken and k.hits_taken == 2 and k.dodges == 2, "split counters reconcile with the encounter totals")
	check(k.focused_time > 0.0 and k.focused_time < root_node.elapsed, "focused time is part of the attempt time (%.2f of %.2f s)" % [k.focused_time, root_node.elapsed])
	# Retry keeps the mode.
	check(await retry_with_key(), "R reloads in Mode B")
	check(scene().control_mode == "B" and king().focus_available and not king().focused, "Retry keeps Mode B and starts unfocused")
	check_fresh("Mode B retry")
	# Back to Mode A: zero focused activity even if Tab is pressed.
	check(await switch_mode_with_key(), "F2 again")
	check(scene().control_mode == "A" and not king().focus_available, "F2 switched back to Mode A")
	root_node = scene()
	k = king()
	await place(Vector3(0, 0, 2), Vector3(0, 0, 1))
	await face(6)
	for i in 3:
		await tap("target_focus")
		await tap("attack")
		await wait(26)
	line = root_node.result_line
	check(root_node.result == "victory" and line.contains("| controls A |") and line.contains("focused 0.00 of"), "Mode A result line: controls A, zero focused time")
	check(line.contains("focus acquired 0,") and line.contains("swings 0/3") and line.contains("sword hits 0/3") and k.focus_acquisitions == 0, "Mode A has zero focused activity")
	root.remove_meta(&"p007_control_mode")
	await load_fresh()
	check(scene().control_mode == "A", "mode metadata cleared after the test (no state left for later tests)")
