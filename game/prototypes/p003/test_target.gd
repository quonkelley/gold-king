extends StaticBody3D
## P003 temporary test target: absorbs impact until its toughness is used up, then breaks.
## A measurement instrument for the gold-power test, not an enemy or breakable-loot object.
## Prototype code; values are exported for playtesting, not final design.

## Emitted on every impact that lands while intact. `broke` is true on the breaking hit.
signal struck(broke: bool)

## Total impact needed to break the target.
@export var toughness: int = 6
## Seconds before a broken target restores itself. 0 means it stays broken until restore() is called.
@export var respawn_delay: float = 0.0

var hits_taken: int = 0
var broken: bool = false

var _damage: int = 0
var _respawn_left: float = 0.0
var _base_color: Color

@onready var _shape: CollisionShape3D = $Shape
@onready var _mesh: MeshInstance3D = $Mesh
@onready var _pips: Label3D = $Pips
@onready var _debris: CPUParticles3D = $Debris


func _ready() -> void:
	# Each target needs its own material so flashing one does not flash the others.
	var mat: StandardMaterial3D = (_mesh.get_surface_override_material(0) as StandardMaterial3D).duplicate()
	_mesh.set_surface_override_material(0, mat)
	_base_color = mat.albedo_color
	restore()


func _physics_process(delta: float) -> void:
	if broken and respawn_delay > 0.0:
		_respawn_left -= delta
		if _respawn_left <= 0.0:
			restore()


func take_impact(impact: int) -> void:
	if broken:
		return
	hits_taken += 1
	_damage += impact
	if _damage >= toughness:
		_break()
		struck.emit(true)
	else:
		_flash()
		_update_pips()
		struck.emit(false)


func restore() -> void:
	_damage = 0
	hits_taken = 0
	broken = false
	_shape.disabled = false
	_mesh.visible = true
	_mesh.scale = Vector3.ONE
	_pips.visible = true
	_update_pips()


## Removes the target without counting a hit, for movement-only trials.
func remove() -> void:
	broken = true
	_respawn_left = INF
	_shape.disabled = true
	_mesh.visible = false
	_pips.visible = false


func _break() -> void:
	broken = true
	_respawn_left = respawn_delay
	_shape.set_deferred("disabled", true)
	_mesh.visible = false
	_pips.visible = false
	_debris.restart()


func _flash() -> void:
	var mat: StandardMaterial3D = _mesh.get_surface_override_material(0)
	mat.albedo_color = Color(1, 1, 1)
	_mesh.scale = Vector3(1.12, 0.92, 1.12)
	var tween: Tween = create_tween()
	tween.set_parallel()
	tween.tween_property(mat, "albedo_color", _base_color, 0.15)
	tween.tween_property(_mesh, "scale", Vector3.ONE, 0.15)


func _update_pips() -> void:
	# Remaining toughness as pips; the same display in every wealth state.
	var left: int = maxi(toughness - _damage, 0)
	_pips.text = "[%s%s]" % ["#".repeat(left), "-".repeat(toughness - left)]
