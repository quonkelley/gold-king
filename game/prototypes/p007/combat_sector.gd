extends RefCounted
## P007 ground-plane sector geometry, shared by the sword arc and the enemy telegraph.
## The hit test and the drawn mesh take the same reach and arc numbers, so what is shown on the
## floor is exactly the region that is tested. Only the horizontal (XZ) plane is used.
## Prototype helper; not a hitbox framework.

## Tolerance that makes the reach and arc edges inclusive despite float rounding.
const EDGE_EPSILON: float = 0.0001


## True when `point` lies inside the sector at `origin` facing `direction`, with radius `reach`
## and total width `arc_degrees`. Edges count as inside. A point on the origin counts as inside.
static func contains(origin: Vector3, direction: Vector3, reach: float, arc_degrees: float, point: Vector3) -> bool:
	var offset: Vector2 = Vector2(point.x - origin.x, point.z - origin.z)
	var distance: float = offset.length()
	if distance > reach + EDGE_EPSILON:
		return false
	if distance <= EDGE_EPSILON:
		return true
	var facing: Vector2 = Vector2(direction.x, direction.z)
	if facing.is_zero_approx():
		return false
	return absf(facing.angle_to(offset)) <= deg_to_rad(arc_degrees) * 0.5 + EDGE_EPSILON


## Flat triangle-fan mesh of the sector, pointing along local +X, lying in the XZ plane.
## Rotate the owning node with yaw_for() to point it along a world direction.
static func build_mesh(reach: float, arc_degrees: float, segments: int = 24) -> ArrayMesh:
	var vertices: PackedVector3Array = PackedVector3Array()
	var half: float = deg_to_rad(arc_degrees) * 0.5
	for i in segments:
		var a0: float = -half + (2.0 * half) * float(i) / float(segments)
		var a1: float = -half + (2.0 * half) * float(i + 1) / float(segments)
		vertices.append(Vector3.ZERO)
		# Local +X is forward; local -Z is the positive-angle side, so yaw rotation stays consistent.
		vertices.append(Vector3(cos(a1), 0.0, -sin(a1)) * reach)
		vertices.append(Vector3(cos(a0), 0.0, -sin(a0)) * reach)
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


## Y rotation that points a build_mesh() sector along `direction` (horizontal only).
static func yaw_for(direction: Vector3) -> float:
	return atan2(-direction.z, direction.x)


## Unshaded, double-sided, see-through material for floor indicators.
static func flat_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = color
	return material


## Adds a flat sector indicator as a child of `parent`, just above the floor.
static func add_indicator(parent: Node3D, node_name: String, reach: float, arc_degrees: float, color: Color, height: float) -> MeshInstance3D:
	var indicator: MeshInstance3D = MeshInstance3D.new()
	indicator.name = node_name
	indicator.mesh = build_mesh(reach, arc_degrees)
	indicator.material_override = flat_material(color)
	indicator.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	indicator.position = Vector3(0.0, height, 0.0)
	parent.add_child(indicator)
	return indicator
