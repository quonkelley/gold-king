extends Node3D
## P006 First Sword: one swing on the `attack` action with a short cooldown and a small sphere
## hit just to the side the King faces. It only opens P006 treasure containers. There are no
## enemies, damage, combos, or aiming; P003's radial strike was the technical reference only.
## Hidden and inert until owned. This tests the value of a purchase, not combat feel.

const TreasureContainer := preload("res://game/prototypes/p006/treasure_container.gd")

## Emitted on every swing that passes the cooldown, with how many containers it opened.
signal swung(hits: int)

## Seconds between swings.
@export var cooldown: float = 0.3
## Radius of the hit sphere, in meters.
@export var reach: float = 1.1
## How far the hit centre sits toward the King's facing side.
@export var forward_offset: float = 0.45
## Height of the hit centre above the King's feet.
@export var hit_height: float = 0.6
## The King's sprite; its flip tells which way he faces.
@export var king_visual: Sprite3D

var owned: bool = false: set = set_owned
var swings: int = 0

var _cooldown_left: float = 0.0
var _query: PhysicsShapeQueryParameters3D
var _sphere: SphereShape3D

@onready var _blade: Node3D = $Blade
@onready var _slash: Sprite3D = $Slash
@onready var _hit_sound: AudioStreamPlayer = $HitSound


func _ready() -> void:
	_sphere = SphereShape3D.new()
	_query = PhysicsShapeQueryParameters3D.new()
	_query.shape = _sphere
	# The slash ring lies flat on the floor at the hit centre.
	_slash.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
	_slash.visible = false
	set_owned(owned)


func set_owned(value: bool) -> void:
	owned = value
	visible = value
	set_physics_process(value)


func _physics_process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	_blade.position.x = facing() * 0.38
	if Input.is_action_just_pressed("attack"):
		swing()


func facing() -> float:
	return -1.0 if king_visual != null and king_visual.flip_h else 1.0


func hit_center() -> Vector3:
	return global_position + Vector3(facing() * forward_offset, hit_height, 0.0)


## Returns how many containers the swing opened, or -1 if it could not swing.
func swing() -> int:
	if not owned or _cooldown_left > 0.0:
		return -1
	_cooldown_left = cooldown
	swings += 1
	_sphere.radius = reach
	_query.transform = Transform3D(Basis(), hit_center())
	_query.exclude = [(get_parent() as CollisionObject3D).get_rid()]
	var hits: int = 0
	for hit: Dictionary in get_world_3d().direct_space_state.intersect_shape(_query, 8):
		var container: TreasureContainer = hit["collider"] as TreasureContainer
		if container != null and container.take_sword_hit():
			hits += 1
	_show_swing()
	if hits > 0:
		_hit_sound.play()
	swung.emit(hits)
	return hits


func _show_swing() -> void:
	# Blade sweeps down toward the facing side; a flat ring marks where the hit landed.
	var side: float = facing()
	_blade.rotation.z = side * deg_to_rad(40.0)
	var blade_tween: Tween = create_tween()
	blade_tween.tween_property(_blade, "rotation:z", -side * deg_to_rad(80.0), cooldown * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	blade_tween.tween_property(_blade, "rotation:z", 0.0, cooldown * 0.5)
	_slash.global_position = Vector3(hit_center().x, global_position.y + 0.05, hit_center().z)
	_slash.visible = true
	_slash.scale = Vector3.ONE * reach * 0.5
	var ring_tween: Tween = create_tween()
	ring_tween.tween_property(_slash, "scale", Vector3.ONE * reach, 0.08)
	ring_tween.tween_callback(_slash.hide)
