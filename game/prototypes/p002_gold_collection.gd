extends Node3D
## P002 prototype controller: owns the run's single gold total and routes pickups to the
## HUD label, the provisional pouch, and the shared pickup sound. Also handles test reset.
## Prototype-local by design; not an inventory or economy system.

const GoldPickup := preload("res://game/gold/gold_pickup.gd")
const GoldPouch := preload("res://game/prototypes/p002/gold_pouch.gd")

var gold_total: int = 0

@onready var _gold_label: Label = $HUD/GoldLabel
@onready var _pouch: GoldPouch = $Player/Pouch
# Shared player so the sound survives the pickup freeing itself; its max_polyphony caps overlap.
@onready var _pickup_sound: AudioStreamPlayer = $PickupSound


func _ready() -> void:
	for pickup: GoldPickup in $Gold.get_children():
		pickup.collected.connect(_on_gold_collected)
	_show_total()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_test"):
		# Reloading restores every pickup, the total, the pouch, and the player start position.
		get_tree().reload_current_scene()


func _on_gold_collected(value: int) -> void:
	gold_total += value
	_show_total()
	_pickup_sound.play()


func _show_total() -> void:
	_gold_label.text = "Gold: %d" % gold_total
	_pouch.show_total(gold_total)
