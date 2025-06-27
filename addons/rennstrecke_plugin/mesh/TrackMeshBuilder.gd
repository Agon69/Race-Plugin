@tool
extends Object
class_name TrackMeshBuilder

static func build_mesh(pts: PackedVector3Array, prof: ProfileResource) -> MeshInstance3D:
	print("BUILDER → build_mesh(pts =", pts.size(), ")")

	# Fallback-Profil
	if prof == null:
		prof = ProfileResource.new()

	var st: SurfaceTool = SurfaceTool.new()
	# Wir verwenden PRIMITIVE_TRIANGLES und setzen alle Indices selbst
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var half_w: float = prof.width * 0.5
	var acc_len: float = 0.0

	for i in range(pts.size() - 1):
		var p0: Vector3 = pts[i]
		var p1: Vector3 = pts[i + 1]
		var frame: Basis = TrackMath.frenet_frame(p0, p1, prof.banking)

		# linke / rechte Eckpunkte
		var l0: Vector3 = p0 + frame.y * -half_w
		var r0: Vector3 = p0 + frame.y *  half_w
		var l1: Vector3 = p1 + frame.y * -half_w
		var r1: Vector3 = p1 + frame.y *  half_w

		var seg_len: float = (p1 - p0).length()

		# UV + Vertex
		st.set_uv(Vector2(acc_len,          0.0)); st.add_vertex(l0)
		st.set_uv(Vector2(acc_len,          1.0)); st.add_vertex(r0)
		st.set_uv(Vector2(acc_len + seg_len,0.0)); st.add_vertex(l1)
		st.set_uv(Vector2(acc_len + seg_len,1.0)); st.add_vertex(r1)

		# Zwei Dreiecke pro Segment
		var base: int = i * 4
		st.add_index(base + 0); st.add_index(base + 1); st.add_index(base + 2)
		st.add_index(base + 1); st.add_index(base + 3); st.add_index(base + 2)

		acc_len += seg_len

	# **WICHTIG**: kein st.index() aufrufen, wir haben alle Indices schon gesetzt!
	st.generate_normals()
	var mesh: ArrayMesh = st.commit()

	# Debug-Material (falls vorhanden)
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.name = "TrackMesh"
	mi.mesh = mesh
	var mat_path := "res://addons/rennstrecke_plugin/resources/debug_material.tres"
	if ResourceLoader.exists(mat_path):
		mi.set_surface_override_material(0, load(mat_path))

	return mi
