extends StaticBody3D
## P003 timed gate: a stationary barrier whose collision and look switch on a fixed cycle.
## Driven entirely by the trial clock it is given, so every trial sees the same schedule.
## If the King is inside the gate when it should close, closing waits until he is clear;
## the schedule itself is not shifted, so later cycles stay on time.
## No damage, pushing, or failure. Prototype code; values are exported for playtesting.

## Seconds the gate stays closed at the start of each cycle (the trial starts closed).
@export var closed_time: float = 1.0
## Seconds the gate stays open in each cycle.
@export var open_time: float = 1.0
## Seconds before closing during which the open gate shows a warning colour.
@export var warn_time: float = 0.3
## Shifts the whole schedule, in seconds. Use to tune when the first opening happens.
@export var phase_offset: float = 0.0

@export var closed_color: Color = Color(0.75, 0.22, 0.15)
@export var warn_color: Color = Color(0.95, 0.75, 0.15)

var is_closed: bool = true

var _material: StandardMaterial3D

@onready var _shape: CollisionShape3D = $Shape
@onready var _mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	_material = (_mesh.get_surface_override_material(0) as StandardMaterial3D).duplicate()
	_mesh.set_surface_override_material(0, _material)
	set_trial_time(0.0)


## True when the fixed schedule says the gate should be closed at trial time `t`.
func scheduled_closed(t: float) -> bool:
	var phase: float = fposmod(t + phase_offset, closed_time + open_time)
	return phase < closed_time


func set_trial_time(t: float) -> void:
	var want_closed: bool = scheduled_closed(t)
	if want_closed and not is_closed and _player_overlaps():
		want_closed = false
	is_closed = want_closed
	_shape.disabled = not is_closed
	var phase: float = fposmod(t + phase_offset, closed_time + open_time)
	var warning: bool = not is_closed and phase >= closed_time + open_time - warn_time
	_mesh.visible = is_closed or warning
	_material.albedo_color = warn_color if warning else closed_color
	# Open-but-warning is drawn as a low strip on the floor so it never looks like a solid wall.
	var height_scale: float = 1.0 if is_closed else 0.12
	_mesh.scale = Vector3(1.0, height_scale, 1.0)
	_mesh.position.y = (_mesh.mesh as BoxMesh).size.y * height_scale * 0.5


func _player_overlaps() -> bool:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _shape.shape
	query.transform = _shape.global_transform
	query.exclude = [get_rid()]
	for hit: Dictionary in get_world_3d().direct_space_state.intersect_shape(query, 4):
		if hit["collider"] is CharacterBody3D:
			return true
	return false
