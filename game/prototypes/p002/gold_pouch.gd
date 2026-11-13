extends Sprite3D
## P002 provisional pouch: shows one of three fill stages for the current gold total and
## stays on the King's trailing (cape) side, mirroring his left/right facing.
## Purely visual: no collision, no shadow, no effect on movement. Hide the node to compare without it.
## Prototype code; not a character-design commitment.

## The King's sprite whose facing this pouch mirrors.
@export var king_visual: Sprite3D

@export_group("Stages")
## Gold total at which the pouch switches from low to partly filled.
@export var partial_at: int = 6
## Gold total at which the pouch switches to overflowing.
@export var overflowing_at: int = 14
@export var low_texture: Texture2D
@export var partial_texture: Texture2D
@export var overflowing_texture: Texture2D

var _side_offset_x: float = 0.0


func _ready() -> void:
	_side_offset_x = absf(position.x)
	show_total(0)


func _process(_delta: float) -> void:
	if king_visual == null:
		return
	flip_h = king_visual.flip_h
	# The King's art faces right when unflipped, so his trailing side is -X; mirror when he turns.
	position.x = _side_offset_x if flip_h else -_side_offset_x


func show_total(total: int) -> void:
	if total >= overflowing_at:
		texture = overflowing_texture
	elif total >= partial_at:
		texture = partial_texture
	else:
		texture = low_texture
