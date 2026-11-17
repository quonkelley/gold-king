extends Node3D
## P007 Combat Foundation: standalone, repeatable combat test arena.
## Not connected to P006's session, treasury, merchant, or expedition. Not the main scene:
## open this scene and use Run Current Scene (F6).
## Owns the encounter only: health display, hit/dodge/defeat feedback, win/loss, retry, the
## developer diagnostics, and one printed result line per attempt for the Prototype Log.
## Retry reloads the scene, so health, positions, timers, and hit records always start fresh.
## Iteration 1 A/B: Mode A is the original movement-based facing; Mode B makes the King's
## optional target focus available (Tab / RB). F2 switches mode and restarts the attempt; the
## mode survives Retry. The result line separates focused from unfocused activity.
## Every value is a P007 Prototype Assumption, not final design.

const CombatKing := preload("res://game/prototypes/p007/combat_king.gd")
const TrainingEnemy := preload("res://game/prototypes/p007/training_enemy.gd")
const CombatSector := preload("res://game/prototypes/p007/combat_sector.gd")

## Developer-only keys; not input-map actions.
const DEBUG_KEY: Key = KEY_F3
const HOLD_ENEMY_KEY: Key = KEY_F4
## Facilitator key: switch Mode A <-> Mode B and restart the attempt.
const MODE_KEY: Key = KEY_F2

const MODE_A: String = "A"
const MODE_B: String = "B"
## Root-window metadata holding the chosen mode, so it survives reload_current_scene() (Retry).
## Only P007 reads it; it is absent (Mode A) until F2 is first pressed.
const MODE_META: StringName = &"p007_control_mode"
const FOCUS_MARKER_HEIGHT: float = 2.35
## Ground ring under the focused enemy. The overhead marker leaves the top of the screen when the
## enemy is about 5 m or more up-screen (windowed check), so the ring keeps focus visible there.
const FOCUS_RING_RADIUS: float = 0.65
const FOCUS_RING_HEIGHT: float = 0.012
const FOCUS_COLOR: Color = Color(0.3, 0.95, 1.0, 0.5)

const ATTACK_PHASE_NAMES: Array[String] = ["idle", "windup", "ACTIVE", "recovery"]
const ENEMY_STATE_NAMES: Array[String] = ["idle", "approach", "WINDUP", "STRIKE", "recovery", "defeated"]
const OUTCOME_NAMES: Array[String] = ["-", "hit", "dodged"]

## "victory", "defeat", or "" while the encounter is running.
var result: String = ""
## The printed result line, kept for tests and for copying from the Output panel.
var result_line: String = ""
var elapsed: float = 0.0
var hits_dealt: int = 0
var hits_taken: int = 0
## Metres walked (not dodging), to tell standing-still play from moving play.
var walked: float = 0.0
## MODE_A or MODE_B for this attempt.
var control_mode: String = MODE_A

var _last_king_position: Vector3
var _focus_ring: MeshInstance3D

@onready var king: CombatKing = $King
@onready var enemy: TrainingEnemy = $TrainingEnemy
@onready var _health_label: Label = $HUD/HealthLabel
@onready var _prompt_label: Label = $HUD/PromptLabel
@onready var _debug_label: Label = $HUD/DebugLabel
@onready var _hit_sound: AudioStreamPlayer = $HitSound
@onready var _mode_label: Label = $HUD/ModeLabel
@onready var _focus_marker: Label3D = $FocusMarker


func _ready() -> void:
	control_mode = current_mode(get_tree())
	_focus_ring = CombatSector.add_indicator(self, "FocusRing", FOCUS_RING_RADIUS, 360.0, FOCUS_COLOR, FOCUS_RING_HEIGHT)
	_focus_ring.visible = false
	# Set before the first physics tick; every attempt starts unfocused.
	king.focus_available = control_mode == MODE_B
	king.focus_changed.connect(_on_focus_changed)
	_last_king_position = king.global_position
	king.sword_hit.connect(_on_sword_hit)
	king.damaged.connect(_on_king_damaged)
	king.dodge_confirmed.connect(_on_dodge_confirmed)
	king.defeated.connect(_on_king_defeated)
	# Counted from the enemy so the killing hit is included before defeat finishes the attempt.
	enemy.hit_taken.connect(_on_enemy_hit_taken)
	enemy.defeated.connect(_on_enemy_defeated)
	_prompt_label.text = "Training encounter"
	_update_health()
	_update_focus_feedback()


static func current_mode(tree: SceneTree) -> String:
	return MODE_B if str(tree.root.get_meta(MODE_META, MODE_A)) == MODE_B else MODE_A


## Records the other mode and restarts, so a mode never changes in the middle of an attempt.
func switch_mode() -> void:
	get_tree().root.set_meta(MODE_META, MODE_A if control_mode == MODE_B else MODE_B)
	get_tree().reload_current_scene()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_test"):
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()
		return
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.physical_keycode == MODE_KEY:
		get_viewport().set_input_as_handled()
		switch_mode()
	elif key.physical_keycode == DEBUG_KEY:
		_debug_label.visible = not _debug_label.visible
	elif key.physical_keycode == HOLD_ENEMY_KEY:
		enemy.held = not enemy.held


func _physics_process(delta: float) -> void:
	if result != "":
		return
	elapsed += delta
	if not king.dodging:
		var step: Vector3 = king.global_position - _last_king_position
		walked += Vector2(step.x, step.z).length()
	_last_king_position = king.global_position


func _process(_delta: float) -> void:
	_place_focus_marker()
	if _debug_label.visible:
		_debug_label.text = debug_text()


func _on_enemy_hit_taken() -> void:
	hits_dealt += 1
	_update_health()


func _on_sword_hit(_target: Node3D) -> void:
	_hit_sound.play()
	_popup(enemy.global_position, "HIT", Color(1.0, 0.92, 0.4))


func _on_king_damaged() -> void:
	hits_taken += 1
	_popup(king.global_position, "-1", Color(1.0, 0.3, 0.25))
	_update_health()


func _on_dodge_confirmed() -> void:
	_popup(king.global_position, "DODGED", Color(0.55, 0.85, 1.0))


func _on_focus_changed(_focused: bool, _reason: String) -> void:
	_update_focus_feedback()


## Marker and HUD line: shown/hidden at once when focus changes, marker follows the target.
func _update_focus_feedback() -> void:
	_place_focus_marker()
	if control_mode == MODE_A:
		_mode_label.text = "Mode A: original free facing    (F2: switch to Mode B)"
		_mode_label.modulate = Color.WHITE
	else:
		_mode_label.text = "Mode B: target focus Tab / RB  -  %s    (F2: switch to Mode A)" % ("FOCUS ON" if king.focused else "focus off")
		_mode_label.modulate = Color(0.45, 1.0, 1.0) if king.focused else Color.WHITE


func _place_focus_marker() -> void:
	var target_ok: bool = king.focused and is_instance_valid(king.focus_target)
	_focus_marker.visible = target_ok
	_focus_ring.visible = target_ok
	if target_ok:
		var ground: Vector3 = king.focus_target.global_position
		_focus_marker.global_position = ground + Vector3(0.0, FOCUS_MARKER_HEIGHT, 0.0)
		_focus_ring.global_position = ground + Vector3(0.0, FOCUS_RING_HEIGHT, 0.0)


func _on_enemy_defeated() -> void:
	# The King would release focus at the end of this tick; do it now so the result line counts it.
	king.validate_focus()
	_finish("victory", "Victory! Enemy defeated.   Retry: R / Back")


func _on_king_defeated() -> void:
	_finish("defeat", "The King is down.   Retry: R / Back")


func _finish(outcome: String, prompt: String) -> void:
	if result != "":
		return
	result = outcome
	_prompt_label.text = prompt
	result_line = "P007 encounter | %s | time %.2f s | King health %d/%d | enemy health %d/%d | hits dealt %d | hits taken %d | swings %d | dodges %d | confirmed dodges %d | cancels %d | enemy attacks %d started, %d completed | walked %.1f m | %s | %s" % [
		outcome, elapsed, king.health, king.max_health, enemy.health, enemy.max_health, hits_dealt, hits_taken,
		king.swings, king.dodges, enemy.dodges_confirmed, king.cancels, enemy.attacks_started, enemy.attacks_completed,
		walked, focus_text(), tuning_text()]
	print(result_line)


## Iteration 1 comparison fields. "Mode B" only means focus was available; these say whether the
## player was actually focused. Mode A always reports zero focused activity.
func focus_text() -> String:
	var r: Dictionary = king.focus_releases
	return "controls %s | focused %.2f of %.2f s | focus acquired %d, released: press %d, range %d, defeat %d, invalid %d, king defeated %d | focused/unfocused: swings %d/%d, sword hits %d/%d, dodges %d/%d, damage taken %d/%d, retreat swings %d/%d, retreat hits %d/%d" % [
		control_mode, king.focused_time, elapsed, king.focus_acquisitions,
		r[CombatKing.FOCUS_RELEASE_PRESS], r[CombatKing.FOCUS_RELEASE_RANGE], r[CombatKing.FOCUS_RELEASE_DEFEAT],
		r[CombatKing.FOCUS_RELEASE_INVALID], r[CombatKing.FOCUS_RELEASE_KING_DEFEATED],
		king.swings_focused, king.swings - king.swings_focused,
		king.sword_hits_focused, king.sword_hits - king.sword_hits_focused,
		king.dodges_focused, king.dodges - king.dodges_focused,
		king.hits_taken_focused, king.hits_taken - king.hits_taken_focused,
		king.retreat_swings_focused, king.retreat_swings - king.retreat_swings_focused,
		king.retreat_hits_focused, king.retreat_hits - king.retreat_hits_focused]


func tuning_text() -> String:
	return "sword %d deg %.2f m, %.2f/%.2f/%.2f s, cancel last %.2f s | dodge %.2f m %.2f s, iframes %.2f-%.2f s, cooldown %.2f s | King health %d | enemy health %d, speed %.1f, range %.2f, windup %.2f (commit %.2f), strike %.2f (%.2f m, %d deg), recovery %.2f" % [
		king.sword_arc_degrees, king.sword_reach, king.sword_windup, king.sword_active, king.sword_recovery, king.dodge_cancel_window,
		king.dodge_distance, king.dodge_duration, king.iframe_start, king.iframe_end, king.dodge_cooldown, king.max_health,
		enemy.max_health, enemy.move_speed, enemy.attack_trigger_range, enemy.windup, enemy.commit_time, enemy.strike_time,
		enemy.strike_reach, enemy.strike_arc_degrees, enemy.recovery]


func debug_text() -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[F3 diagnostics]  time %.2f s%s" % [elapsed, "   ENEMY HELD (F4)" if enemy.held else ""])
	lines.append("Mode %s | focus %s%s" % [control_mode, "ON" if king.focused else "off",
		" (%.2f m)" % king.ground_distance_to(enemy) if is_instance_valid(enemy) else ""])
	lines.append("King: sword %s %.2f s | facing %d | attack dir (%.2f, %.2f)" % [
		ATTACK_PHASE_NAMES[king.attack_phase], king.attack_elapsed, king.facing_index, king.attack_dir.x, king.attack_dir.z])
	lines.append("      dodge %s%s %.2f s | cooldown %.2f s | health %d/%d" % [
		"yes" if king.dodging else "no", " INVULNERABLE" if king.is_invulnerable() else "", king.dodge_elapsed,
		king.dodge_cooldown_left, king.health, king.max_health])
	lines.append("Enemy: %s %.2f s | %s | dir (%.2f, %.2f) | last strike %s | health %d/%d" % [
		ENEMY_STATE_NAMES[enemy.state], enemy.state_time, "committed" if enemy.committed else "aiming",
		enemy.strike_dir.x, enemy.strike_dir.z, OUTCOME_NAMES[enemy.strike_outcome], enemy.health, enemy.max_health])
	var gap: Vector3 = enemy.global_position - king.global_position
	lines.append("Distance %.2f m | swings %d hits %d | dodges %d confirmed %d cancels %d | taken %d" % [
		Vector2(gap.x, gap.z).length(), king.swings, hits_dealt, king.dodges, enemy.dodges_confirmed, king.cancels, hits_taken])
	lines.append(focus_text().replace(" | ", "\n"))
	lines.append(tuning_text().replace(" | ", "\n"))
	return "\n".join(lines)


func _update_health() -> void:
	_health_label.text = "King %s     Enemy %s" % [
		"♥".repeat(king.health) + "♡".repeat(king.max_health - king.health),
		"●".repeat(enemy.health) + "○".repeat(enemy.max_health - enemy.health)]


## Short floating text above a combatant; placeholder feedback, not a VFX system.
func _popup(at: Vector3, text: String, color: Color) -> void:
	var label: Label3D = Label3D.new()
	label.text = text
	label.modulate = color
	label.outline_modulate = Color(0.05, 0.03, 0.02, 1.0)
	label.font_size = 56
	label.outline_size = 12
	label.pixel_size = 0.006
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	add_child(label)
	label.global_position = at + Vector3(0.0, 2.1, 0.0)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "global_position:y", at.y + 2.7, 0.55)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.55)
	tween.tween_callback(label.queue_free)
