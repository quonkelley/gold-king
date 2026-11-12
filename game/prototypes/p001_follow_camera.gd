extends Camera3D
## P001 prototype camera: rigid follow at a fixed elevated angle, no player-controlled rotation.
## Projection, FOV, and orthographic size are tuned on the Camera3D itself in the inspector.
## Prototype defaults only; not a production camera.

## Node the camera keeps centered.
@export var target: Node3D
## Downward tilt from horizontal, in degrees.
@export_range(10.0, 89.0) var pitch_degrees: float = 52.0
## Distance from the target along the view direction, in meters. In orthographic mode this affects clipping, not zoom.
@export var distance: float = 12.0


func _ready() -> void:
	_follow()


func _process(_delta: float) -> void:
	_follow()


func _follow() -> void:
	if target == null:
		return
	var pitch: float = deg_to_rad(pitch_degrees)
	global_position = target.global_position + Vector3(0.0, sin(pitch), cos(pitch)) * distance
	global_rotation = Vector3(-pitch, 0.0, 0.0)
