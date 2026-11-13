extends Node3D
## P003 temporary strike: one button, fixed cooldown, radial reach around the King.
## Only P003 test targets react. A measurement instrument for gold power, not a combat system.
## Facing is not used for aiming; the radial reach keeps the test forgiving.
## Prototype code; values are exported for playtesting, not final design.

const TestTarget := preload("res://game/prototypes/p003/test_target.gd")

## Emitted on every strike press that passes the cooldown, whether or not it lands.
signal attempted

## Impact applied per landed strike. Set by the P003 controller from the current wealth state.
@export var impact: int = 2
## Seconds between strikes. Identical in every wealth state.
@export var cooldown: float = 0.3
## Radius of the strike around the King's hip, in meters.
@export var reach: float = 1.0
## Height of the strike centre above the King's feet.
@export var hit_height: float = 0.75

var _cooldown_left: float = 0.0
var _query: PhysicsShapeQueryParameters3D
var _sphere: SphereShape3D

@onready var _ring: Sprite3D = $Ring
@onready var _hit_sound: AudioStreamPlayer = $HitSound


func _ready() -> void:
	_sphere = SphereShape3D.new()
	_query = PhysicsShapeQueryParameters3D.new()
	_query.shape = _sphere
	# Lie the ring flat on the floor around the King.
	_ring.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
	_ring.visible = false


func _physics_process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	if Input.is_action_just_pressed("strike") and _cooldown_left == 0.0:
		_cooldown_left = cooldown
		_strike()


func _strike() -> void:
	attempted.emit()
	_show_ring()
	_sphere.radius = reach
	_query.transform = Transform3D(Basis(), global_position + Vector3(0.0, hit_height, 0.0))
	_query.exclude = [(get_parent() as CollisionObject3D).get_rid()]
	var landed: bool = false
	for hit: Dictionary in get_world_3d().direct_space_state.intersect_shape(_query, 8):
		var target: TestTarget = hit["collider"] as TestTarget
		if target != null and not target.broken:
			target.take_impact(impact)
			landed = true
	if landed:
		_hit_sound.play()


func _show_ring() -> void:
	# Flat ring on the floor showing the strike's reach; identical in every wealth state.
	_ring.visible = true
	_ring.scale = Vector3.ONE * reach * 0.6
	var tween: Tween = create_tween()
	tween.tween_property(_ring, "scale", Vector3.ONE * reach, 0.08)
	tween.tween_callback(_ring.hide)
