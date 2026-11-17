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
