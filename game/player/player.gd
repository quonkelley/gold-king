extends CharacterBody3D
## P001 prototype player: ground-plane movement, collision, and left/right facing.
## Prototype code; tuning values are exported for playtesting, not final design.

@export_group("Movement")
## Top speed in meters per second at full input.
@export var move_speed: float = 5.0
## Rate (m/s per second) at which velocity approaches the input target. High values feel near-instant.
@export var acceleration: float = 80.0
## Rate (m/s per second) at which velocity returns to zero without input. High values stop near-instantly.
@export var deceleration: float = 120.0

@export_group("Facing")
## Minimum horizontal input before the sprite flips. Prevents flicker from small stick drift or pure up/down input.
@export var facing_threshold: float = 0.2

@onready var _visual: Sprite3D = $Visual


func _physics_process(delta: float) -> void:
	# get_vector caps length at 1, so diagonals are not faster, and keeps partial stick tilt.
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# The camera never yaws in P001, so screen-up maps directly to world -Z.
	var target: Vector3 = Vector3(input.x, 0.0, input.y) * move_speed
	var rate: float = acceleration if input != Vector2.ZERO else deceleration
	velocity = velocity.move_toward(target, rate * delta)
	move_and_slide()
	_update_facing(input.x)


func _update_facing(horizontal_input: float) -> void:
	# Only meaningful horizontal input changes facing; idle and pure vertical movement keep the last facing.
	if horizontal_input >= facing_threshold:
		_visual.flip_h = false
	elif horizontal_input <= -facing_threshold:
		_visual.flip_h = true
