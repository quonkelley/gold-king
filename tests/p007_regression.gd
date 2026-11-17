extends SceneTree
## P007 regression checks: scene isolation, eight-direction facing, sector geometry, sword timing
## and hit limits, dodge, invulnerability, cancellation, enemy states and first-contact strike
## resolution, defeat, retry, and input isolation. Mechanical only; never feel, readability,
## fairness, balance, or enjoyment.
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
	for action: String in MOVES + ["attack", "dodge", "restart_test"]:
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
