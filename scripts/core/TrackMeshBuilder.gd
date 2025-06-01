@tool
extends Node3D

func _enter_tree():
	print("TrackMeshBuilder: _enter_tree() aufgerufen")

func _ready():
	print("TrackMeshBuilder: _ready() aufgerufen")

func build(params: Dictionary, points: PackedVector3Array) -> void:
	print("TrackMeshBuilder: build() gestartet")
	print("TrackMeshBuilder: Parameter:", params)
	print("TrackMeshBuilder: Punkteanzahl:", points.size())

	if points.size() < 2:
		push_error("TrackMeshBuilder: Weniger als 2 Punkte, kein Mesh möglich.")
		return

	var total_width = params.get("width", 2.0)
	var half_w = total_width * 0.5

	var vertices = PackedVector3Array()
	var indices  = PackedInt32Array()
	var uvs      = PackedVector2Array()

	for i in range(points.size() - 1):
		var p1 = points[i]
		var p2 = points[i + 1]
		var dir = (p2 - p1).normalized()
		var up  = Vector3.UP
		var right = dir.cross(up).normalized() * half_w

		var h = 0.05
		var v0 = p1 + right + Vector3(0, h, 0)
		var v1 = p1 - right + Vector3(0, h, 0)
		var v2 = p2 - right + Vector3(0, h, 0)
		var v3 = p2 + right + Vector3(0, h, 0)

		var base = vertices.size()
		vertices.append(v0)
		vertices.append(v1)
		vertices.append(v2)
		vertices.append(v3)

		uvs.append(Vector2(i, 0))
		uvs.append(Vector2(i, 1))
		uvs.append(Vector2(i + 1, 1))
		uvs.append(Vector2(i + 1, 0))

		indices.append(base + 0)
		indices.append(base + 1)
		indices.append(base + 2)
		indices.append(base + 0)
		indices.append(base + 2)
		indices.append(base + 3)

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for j in range(vertices.size()):
		st.add_normal(Vector3.UP)
		st.add_uv(uvs[j])
		st.add_vertex(vertices[j])

	st.index()
	st.add_indices(indices)
	st.generate_normals()
	var mesh = st.commit()

	if get_parent().has_node("TrackInstance"):
		get_parent().get_node("TrackInstance").queue_free()

	var mi = MeshInstance3D.new()
	mi.name = "TrackInstance"
	mi.mesh = mesh
	get_parent().add_child(mi)

	print("TrackMeshBuilder: Mesh-Extrusion abgeschlossen. TrackInstance erzeugt")
