extends Node3D
## P006 placeholder traveling merchant. Visual stand-in plus a "met" flag and a floating caption.
## It has no AI, dialogue system, or quest logic; the expedition and hub decide what meeting or
## visiting it does. Name, look, and caption text are placeholders, not narrative canon.

## Horizontal distance from the merchant within which the interact input reaches it.
@export var interact_radius: float = 2.0
## Caption before and after the King has met the merchant on this expedition.
@export var idle_caption: String = "Traveling Merchant"
@export var met_caption: String = "Traveling Merchant\n\"I'll set up at your camp — if you make it back.\""

var met: bool = false

@onready var _caption: Label3D = $Caption


func _ready() -> void:
	_caption.text = idle_caption


func in_reach(point: Vector3) -> bool:
	return Vector2(point.x - global_position.x, point.z - global_position.z).length() <= interact_radius


## Marks the merchant as met. Returns false if it already was, so a repeat press does nothing.
func mark_met() -> bool:
	if met:
		return false
	met = true
	_caption.text = met_caption
	var tween: Tween = create_tween()
	_caption.scale = Vector3.ONE * 1.3
	tween.tween_property(_caption, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return true
