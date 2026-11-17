extends CharacterBody3D
## P007 placeholder Training Enemy: health, sword-hit reaction, and defeat.
## No species, lore, or canon. Sword hits flash it but never interrupt it (no stagger).
## Every value is a P007 Prototype Assumption, not final enemy design.

const CombatSector := preload("res://game/prototypes/p007/combat_sector.gd")

## Took one sword hit (health already reduced).
signal hit_taken
## Health reached zero.
signal defeated

@export_group("Health")
## Sword hits needed to defeat the enemy.
@export var max_health: int = 3

var health: int = 0
## Developer freeze (F4): the enemy stops acting so hit boundaries can be inspected.
var held: bool = false

@onready var _visual: Sprite3D = $Visual
@onready var _health_label: Label3D = $HealthLabel
@onready var _collision: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	health = max_health
	# Exact ground point that the sword's arc test uses.
	CombatSector.add_indicator(self, "FootMarker", 0.1, 360.0, Color(1.0, 0.45, 0.4, 0.95), 0.025)
	_update_health_label()


func is_alive() -> bool:
	return health > 0


## Applies one sword hit. Returns false when the enemy is already defeated.
func take_sword_hit() -> bool:
	if not is_alive():
		return false
	health -= 1
	_update_health_label()
	hit_taken.emit()
	if health <= 0:
		_defeat()
	else:
		_flash(Color(1.0, 0.35, 0.3))
	return true


func _defeat() -> void:
	velocity = Vector3.ZERO
	# The body no longer blocks the King once defeated.
	_collision.set_deferred("disabled", true)
	_visual.modulate = Color(0.35, 0.35, 0.38, 0.85)
	_health_label.text = "DEFEATED"
	defeated.emit()


func _flash(color: Color) -> void:
	_visual.modulate = color
	var tween: Tween = create_tween()
	tween.tween_property(_visual, "modulate", Color.WHITE, 0.18)


func _update_health_label() -> void:
	_health_label.text = "●".repeat(maxi(health, 0)) + "○".repeat(maxi(max_health - health, 0))
