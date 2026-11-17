extends Node3D
## P007 Combat Foundation: standalone, repeatable combat test arena.
## Not connected to P006's session, treasury, merchant, or expedition. Not the main scene:
## open this scene and use Run Current Scene (F6).
## Retry reloads the scene, so health, positions, timers, and hit records always start fresh.
## Every value is a P007 Prototype Assumption, not final design.

const CombatKing := preload("res://game/prototypes/p007/combat_king.gd")

## Developer-only key that shows or hides the diagnostics panel. Not an input-map action.
const DEBUG_KEY: Key = KEY_F3

@onready var king: CombatKing = $King
@onready var _debug_label: Label = $HUD/DebugLabel


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_test"):
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()
	elif event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).physical_keycode == DEBUG_KEY:
		_debug_label.visible = not _debug_label.visible


func _process(_delta: float) -> void:
	if _debug_label.visible:
		_debug_label.text = debug_text()


func debug_text() -> String:
	return "facing %d (%.2f, %.2f)" % [king.facing_index, king.facing_dir.x, king.facing_dir.z]
