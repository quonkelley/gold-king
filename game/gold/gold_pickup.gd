extends Area3D
## P002 prototype gold pickup: collected once when the player's body enters its small trigger.
## Knows nothing about totals, HUD, or sound; it only reports its value and plays its own pop.
## Prototype code; values are exported for playtesting, not final design.

signal collected(value: int)

## Gold awarded on collection.
@export var value: int = 1

@export_group("Bob")
## Vertical bob amplitude of the coin art in meters. Set to 0 to disable bobbing. The trigger never moves.
@export var bob_height: float = 0.06
## Bob cycles per second.
@export var bob_speed: float = 0.8

@export_group("Pop")
## Peak scale of the coin art before it shrinks away.
@export var pop_scale: float = 1.4
## Seconds to grow to the peak scale.
@export var pop_grow_time: float = 0.05
## Seconds to shrink from the peak to nothing.
@export var pop_shrink_time: float = 0.1

var _collected: bool = false
var _coin_rest_y: float = 0.0
var _bob_phase: float = 0.0

@onready var _coin: Sprite3D = $Coin
@onready var _sparkle: CPUParticles3D = $Sparkle


func _ready() -> void:
	_coin_rest_y = _coin.position.y
	# Position-derived phase keeps neighbouring coins out of lockstep without randomness.
	_bob_phase = global_position.x * 0.9 + global_position.z * 0.6
	body_entered.connect(_on_body_entered)


func _process(_delta: float) -> void:
	if bob_height == 0.0:
		return
	var t: float = Time.get_ticks_msec() / 1000.0
	_coin.position.y = _coin_rest_y + sin(t * bob_speed * TAU + _bob_phase) * bob_height


func _on_body_entered(body: Node3D) -> void:
	# Only the player is a CharacterBody3D in P002; the guard prevents double counting
	# when several overlap signals arrive before monitoring switches off.
	if _collected or not body is CharacterBody3D:
		return
	_collected = true
	set_deferred("monitoring", false)
	set_process(false)
	collected.emit(value)
	_play_pop()


func _play_pop() -> void:
	_sparkle.restart()
	var tween: Tween = create_tween()
	tween.tween_property(_coin, "scale", Vector3.ONE * pop_scale, pop_grow_time)
	tween.tween_property(_coin, "scale", Vector3.ZERO, pop_shrink_time)
	# Keep the node alive until the sparkle burst has finished, then remove it.
	var remaining: float = maxf(_sparkle.lifetime - pop_grow_time - pop_shrink_time, 0.0)
	tween.tween_interval(remaining)
	tween.tween_callback(queue_free)
