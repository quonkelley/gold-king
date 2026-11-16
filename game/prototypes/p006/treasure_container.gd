extends StaticBody3D
## P006 breakable treasure container. Only the purchased sword can open it, once per expedition;
## it then reports itself so the expedition can release bonus gold. It never creates or counts gold.
## A fresh expedition is a fresh scene, so containers reset by construction.
## Placeholder visuals; a demonstration of the sword's functional value, not combat.

signal broke_open(container: Node3D)

var broken: bool = false

@onready var _closed: Node3D = $Closed
@onready var _open: Node3D = $Open
@onready var _shape: CollisionShape3D = $Shape
@onready var _debris: CPUParticles3D = $Debris


func _ready() -> void:
	_open.visible = false


## Called by the sword. Returns true only for the hit that opens it.
func take_sword_hit() -> bool:
	if broken:
		return false
	broken = true
	_closed.visible = false
	_open.visible = true
	# Broken remains no longer block the King.
	_shape.set_deferred("disabled", true)
	_debris.restart()
	broke_open.emit(self)
	return true
