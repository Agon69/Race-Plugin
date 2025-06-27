@tool
extends Object
class_name TrackMath

static func frenet_frame(p_prev: Vector3, p_next: Vector3, banking_deg: float) -> Basis:
	var tangent = (p_next - p_prev).normalized()
	var normal  = tangent.cross(Vector3.UP).normalized()
	var binorm  = tangent.cross(normal)
	var frame   = Basis(tangent, normal, binorm).orthonormalized()
	return frame.rotated(tangent, deg_to_rad(banking_deg))
