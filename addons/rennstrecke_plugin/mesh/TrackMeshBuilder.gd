@tool
extends Object
class_name TrackMeshBuilder

# --------------------------------------------------------------------
#   Static method to build a track mesh based on baked path points
#   and a given profile (width, banking, etc.)
# --------------------------------------------------------------------
static func build_mesh(pts: PackedVector3Array, prof: ProfileResource) -> MeshInstance3D:
	print("BUILDER → build_mesh(pts =", pts.size(), ")")

	# Use fallback profile if none provided
	if prof == null:
		prof = ProfileResource.new()

	var st: SurfaceTool = SurfaceTool.new()

	# Begin building a triangle mesh manually
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Half the track width
	var half_w: float = prof.width * 0.5
	var acc_len: float = 0.0  # For UV mapping along track length

	# Generate geometry for each track segment
	for i in range(pts.size() - 1):
		var p0: Vector3 = pts[i]
		var p1: Vector3 = pts[i + 1]

		# Calculate frenet frame between two points (orientation of segment)
		var frame: Basis = TrackMath.frenet_frame(p0, p1, prof.banking)

		# Calculate left/right edges of segment
		var l0: Vector3 = p0 + frame.y * -half_w
		var r0: Vector3 = p0 + frame.y *  half_w
		var l1: Vector3 = p1 + frame.y * -half_w
		var r1: Vector3 = p1 + frame.y *  half_w

		var seg_len: float = (p1 - p0).length()

		# Set UVs and vertices (4 per segment)
		st.set_uv(Vector2(acc_len,           0.0)); st.add_vertex(l0)
		st.set_uv(Vector2(acc_len,           1.0)); st.add_vertex(r0)
		st.set_uv(Vector2(acc_len + seg_len, 0.0)); st.add_vertex(l1)
		st.set_uv(Vector2(acc_len + seg_len, 1.0)); st.add_vertex(r1)

		# Add two triangles per quad segment using manual indices
		var base: int = i * 4
		st.add_index(base + 0); st.add_index(base + 2); st.add_index(base + 1)
		st.add_index(base + 1); st.add_index(base + 2); st.add_index(base + 3)

		# Increase accumulated length for UV spacing
		acc_len += seg_len

	# Generate normals based on geometry (important for lighting)
	st.generate_normals()

	# Final mesh
	var mesh: ArrayMesh = st.commit()

	# Wrap the mesh in a MeshInstance3D so it can be placed in the world
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.name = "TrackMesh"
	mi.mesh = mesh

	# Load and assign debug material if available
	var mat_path := "res://addons/rennstrecke_plugin/resources/debug_material.tres"
	if ResourceLoader.exists(mat_path):
		mi.set_surface_override_material(0, load(mat_path))

	return mi
