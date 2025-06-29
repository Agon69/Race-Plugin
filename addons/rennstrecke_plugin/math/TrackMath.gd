@tool
extends Object
class_name TrackMath

static func frenet_frame(p_prev: Vector3, p_next: Vector3, banking_deg: float) -> Basis:
	# Compute the tangent vector (direction of travel between two points)
	var tangent: Vector3 = (p_next - p_prev).normalized()
	
	# Derive a normal vector orthogonal to the tangent using the world up axis
	var normal: Vector3 = tangent.cross(Vector3.UP).normalized()
	
	# Compute the binormal as the cross product of tangent and normal
	var binorm: Vector3 = tangent.cross(normal)
	
	# Build an orthonormal basis from tangent, normal, binormal
	var frame: Basis = Basis(tangent, normal, binorm).orthonormalized()
	
	# Apply banking rotation around the tangent axis
	return frame.rotated(tangent, deg_to_rad(banking_deg))
