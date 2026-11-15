extends "res://game/gold/gold_pickup.gd"
## P004 spilled or dropped coin. Same look, trigger, and pop as the P002 pickup, with two
## P004-local differences:
## - It cannot be collected while it is still scattering (hopping to its landing spot).
## - Before giving any collection feedback it asks the P004 controller whether the King
##   actually receives it. The controller resolves ownership first, so a coin the thief
##   already claimed never pops, sparkles, or plays a sound for the King.
## The P002 pickup script is unchanged; this overrides only its body-entered handler.

## Set by the P004 controller. Called with this coin; returns true if the King receives it.
var try_take: Callable
## False while scattering. The thief also ignores coins that have not landed.
var collectable: bool = false
## True once the King received this coin and its collection feedback played.
var popped: bool = false


## Hops from `from` to `to` over `time` seconds, then becomes collectable.
func scatter(from: Vector3, to: Vector3, time: float, height: float) -> void:
	monitoring = false
	global_position = from
	# The tween belongs to this coin, so it stops safely if the coin is freed mid-hop. It runs on
	# physics ticks so the landing moment is deterministic for repeatable trials and tests.
	var tween: Tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_method(func(t: float) -> void:
		global_position = from.lerp(to, t) + Vector3.UP * height * 4.0 * t * (1.0 - t), 0.0, 1.0, time)
	tween.tween_callback(_land)


## Removes the coin silently because the thief took it. No King feedback.
func take_by_thief() -> void:
	_collected = true
	collectable = false
	set_deferred("monitoring", false)
	queue_free()


func _land() -> void:
	collectable = true
	monitoring = true


func _on_body_entered(body: Node3D) -> void:
	if _collected or not collectable or not body is CharacterBody3D:
		return
	if not try_take.is_valid() or not try_take.call(self):
		return
	_collected = true
	collectable = false
	popped = true
	set_deferred("monitoring", false)
	set_process(false)
	_play_pop()
