extends Node3D
## P002 prototype controller: owns the run's single gold total and routes pickups to the
## HUD label, the provisional pouch, and the shared pickup sound. Also handles test reset
## and selects the gold presentation for the floating vs. grounded comparison.
## Prototype-local by design; not an inventory or economy system.

const GoldPickup := preload("res://game/gold/gold_pickup.gd")
const GoldPouch := preload("res://game/prototypes/p002/gold_pouch.gd")

enum Presentation { FLOATING, GROUNDED }

## How every pickup in this scene is shown. Collection behavior is identical in both.
@export var gold_presentation: Presentation = Presentation.FLOATING

@export_group("Feedback")
## Minimum seconds between pickup sounds. Coins collected closer together than this still
## count but share one sound, so clusters read as distinct clinks instead of a stacked smear.
@export var sound_min_interval: float = 0.045
## Peak scale of the HUD label pulse on each collection. Set to 1 to disable the pulse.
@export var hud_pulse_scale: float = 1.15
## Seconds for the HUD pulse to grow and settle.
@export var hud_pulse_time: float = 0.12

var gold_total: int = 0

var _last_sound_msec: int = -1000000
var _hud_tween: Tween

@onready var _gold_label: Label = $HUD/GoldLabel
@onready var _pouch: GoldPouch = $Player/Pouch
# Shared player so the sound survives the pickup freeing itself; its max_polyphony caps overlap.
@onready var _pickup_sound: AudioStreamPlayer = $PickupSound


func _ready() -> void:
	var grounded: bool = gold_presentation == Presentation.GROUNDED
	for pickup: GoldPickup in $Gold.get_children():
		pickup.apply_presentation(grounded)
		pickup.collected.connect(_on_gold_collected)
	_show_total()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_test"):
		# Reloading restores every pickup, the total, the pouch, and the player start position.
		get_tree().reload_current_scene()


func _on_gold_collected(value: int) -> void:
	gold_total += value
	_show_total()
	_pulse_hud()
	var now: int = Time.get_ticks_msec()
	if now - _last_sound_msec >= int(sound_min_interval * 1000.0):
		_last_sound_msec = now
		_pickup_sound.play()


func _show_total() -> void:
	_gold_label.text = "Gold: %d" % gold_total
	_pouch.show_total(gold_total)


func _pulse_hud() -> void:
	if _hud_tween != null:
		_hud_tween.kill()
	# Scale around the label's left-middle so the number grows in place.
	_gold_label.pivot_offset = Vector2(0.0, _gold_label.size.y * 0.5)
	_gold_label.scale = Vector2.ONE * hud_pulse_scale
	_hud_tween = create_tween()
	_hud_tween.tween_property(_gold_label, "scale", Vector2.ONE, hud_pulse_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
