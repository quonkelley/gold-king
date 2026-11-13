extends Area3D
## P002 prototype gold pickup: collected once when the player's body enters its small trigger.
## Knows nothing about totals, HUD, or sound; it only reports its value and plays its own pop.
## Supports two presentations for comparison: floating (upright, bobbing) and grounded (lying flat).
## Prototype code; values are exported for playtesting, not final design.

signal collected(value: int)

## Gold awarded on collection.
@export var value: int = 1

@export_group("Bob")
## Vertical bob amplitude of the coin art in meters (floating only). Set to 0 to disable. The trigger never moves.
@export var bob_height: float = 0.06
## Bob cycles per second.
@export var bob_speed: float = 0.8

@export_group("Grounded")
## Height of the flat coin above the floor in grounded presentation; just enough to avoid z-fighting.
@export var ground_height: float = 0.02

@export_group("Pop")
## Peak scale of the coin art before it shrinks away.
@export var pop_scale: float = 1.5
## How far the coin art lifts while popping, in meters.
@export var pop_rise: float = 0.35
## Seconds to grow to the peak scale.
@export var pop_grow_time: float = 0.06
## Seconds to shrink from the peak to nothing.
@export var pop_shrink_time: float = 0.12
## Color multiplier the coin flashes to as it pops.
@export var pop_flash: Color = Color(1.8, 1.7, 1.3)
## Peak scale of the star glint.
@export var glint_scale: float = 1.0

var _collected: bool = false
var _grounded: bool = false
var _coin_rest_y: float = 0.0
var _bob_phase: float = 0.0

@onready var _coin: Sprite3D = $Coin
@onready var _glint: Sprite3D = $Glint
@onready var _sparkle: CPUParticles3D = $Sparkle


func _ready() -> void:
	_coin_rest_y = _coin.position.y
	# Position-derived phase keeps neighbouring coins out of lockstep without randomness.
	_bob_phase = global_position.x * 0.9 + global_position.z * 0.6
	_glint.visible = false
	body_entered.connect(_on_body_entered)


## Switches between the floating (default) and grounded presentations. Visual only:
## the trigger, value, and collection behavior are identical in both.
func apply_presentation(grounded: bool) -> void:
	_grounded = grounded
	if grounded:
		# Lie flat on the floor, facing up; the elevated camera sees it as a slightly squashed disc.
		_coin.billboard = BaseMaterial3D.BILLBOARD_DISABLED
		_coin.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
		_coin.position.y = ground_height
		_coin.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	else:
		_coin.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		_coin.rotation = Vector3.ZERO
		_coin.position.y = _coin_rest_y
		_coin.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	# Effects start from wherever the coin art is.
	_glint.position.y = _coin.position.y + 0.1
	_sparkle.position.y = _coin.position.y


func _process(_delta: float) -> void:
	if _grounded or bob_height == 0.0:
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
	var pop_time: float = pop_grow_time + pop_shrink_time

	# Coin: flash bright and lift while growing, then shrink away.
	var coin_tween: Tween = create_tween()
	coin_tween.set_parallel()
	coin_tween.tween_property(_coin, "scale", Vector3.ONE * pop_scale, pop_grow_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	coin_tween.tween_property(_coin, "modulate", pop_flash, pop_grow_time)
	coin_tween.tween_property(_coin, "position:y", _coin.position.y + pop_rise, pop_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	coin_tween.chain().tween_property(_coin, "scale", Vector3.ZERO, pop_shrink_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Glint: a quick star flash at the coin, which marks each collection even inside a cluster.
	_glint.visible = true
	_glint.scale = Vector3.ZERO
	var glint_tween: Tween = create_tween()
	glint_tween.tween_property(_glint, "scale", Vector3.ONE * glint_scale, pop_grow_time)
	glint_tween.tween_property(_glint, "scale", Vector3.ZERO, pop_shrink_time)

	# Keep the node alive until the sparkle burst has finished, then remove it.
	var cleanup: Tween = create_tween()
	cleanup.tween_interval(maxf(_sparkle.lifetime, pop_time))
	cleanup.tween_callback(queue_free)
