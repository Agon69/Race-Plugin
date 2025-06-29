@tool
extends Node3D
class_name RoadPoint

func _ready() -> void:
	if Engine.is_editor_hint():
		_add_preview_sphere()

func _add_preview_sphere() -> void:
	# Only add the preview sphere once per node
	if has_node("PreviewMesh"):
		return

	# Create a MeshInstance3D for the preview sphere
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = "PreviewMesh"
	mesh.mesh = SphereMesh.new()
	mesh.scale = Vector3.ONE * 4            # Adjust sphere size
	mesh.material_override = _make_preview_material()
	add_child(mesh)
	mesh.owner = null                       # Do not save this node in the scene file

func _make_preview_material() -> StandardMaterial3D:
	# Create a simple material for the preview sphere
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color   = Color(1.0, 0.3, 0.0)   # Bright orange color
	mat.metallic       = 0.0
	mat.roughness      = 1.0
	mat.transparency   = BaseMaterial3D.TRANSPARENCY_DISABLED
	return mat
