@tool
extends Node3D
class_name RoadPoint


func _ready() -> void:
	if Engine.is_editor_hint():
		_add_preview_sphere()

func _add_preview_sphere() -> void:
	if has_node("PreviewMesh"):
		return  # Nicht doppelt hinzufügen

	var mesh := MeshInstance3D.new()
	mesh.name = "PreviewMesh"
	mesh.mesh = SphereMesh.new()
	mesh.scale = Vector3.ONE * 10  # Größe anpassen
	mesh.material_override = _make_preview_material()
	add_child(mesh)
	mesh.owner = null  # Kein Speichern in Szene

func _make_preview_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.3, 0.0)  # z. B. orange
	mat.metallic = 0.0
	mat.roughness = 1.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	return mat
