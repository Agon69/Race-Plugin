@tool
extends Node3D
class_name RoadContainer

@export var track_id: int = 0
@export var profile: ProfileResource
@export var bake_step: float = 0.05

var _preset_name: String = "race"

@export_enum("race", "offroad", "street")
var preset_name: String = "race":
	set(value):
		if _preset_name == value:
			return
		_preset_name = value
		_apply_preset(value)
	get:
		return _preset_name

@onready var path: Path3D = Path3D.new()

func _ready() -> void:
	if not has_node("Path3D"):
		add_child(path)
	if path.curve == null:
		path.curve = Curve3D.new()

	_apply_preset(_preset_name)
	print("CONTAINER ✓ ready (track_id =", track_id, ")")

func _apply_preset(name: String) -> void:
	var res_path := "res://addons/rennstrecke_plugin/resources/presets/%s.tres" % name
	if ResourceLoader.exists(res_path):
		profile = load(res_path)
		print("CONTAINER ✓ preset =", name)
	else:
		push_warning("Preset nicht gefunden: " + res_path)

# ✅ Angepasste Signatur!
func build_mesh(step: float = bake_step, close_track: bool = true) -> void:
	print("CONTAINER[", track_id, "] → build_mesh(", step, ", closed =", close_track, ")")

	var ctrl: Array[Vector3] = []
	for n in get_children():
		if n is RoadPoint:
			ctrl.append(n.transform.origin)

	# ✅ Schleife schließen, falls aktiviert
	if close_track and ctrl.size() >= 2:
		ctrl.append(ctrl[0])

	if ctrl.size() < 2:
		push_warning("⚠️ Zu wenig Punkte!")
		return

	var curve := path.curve
	curve.clear_points()
	for p in ctrl:
		curve.add_point(p)
	for i in range(ctrl.size()):
		var in_t := Vector3.ZERO
		var out_t := Vector3.ZERO
		if i > 0 and i < ctrl.size() - 1:
			var tan := (ctrl[i + 1] - ctrl[i - 1]) * 0.25
			in_t = -tan
			out_t = tan
		curve.set_point_in(i, in_t)
		curve.set_point_out(i, out_t)

	curve.bake_interval = step
	var pts: PackedVector3Array = curve.get_baked_points()

	if has_node("TrackMesh"):
		get_node("TrackMesh").queue_free()

	var mi := TrackMeshBuilder.build_mesh(pts, profile)
	add_child(mi)
	mi.owner = get_owner()

	if has_node("TrackCollision"):
		get_node("TrackCollision").queue_free()

	var sb := StaticBody3D.new()
	sb.name = "TrackCollision"
	sb.transform = mi.transform
	add_child(sb)
	sb.owner = get_owner()

	var cs := CollisionShape3D.new()
	sb.add_child(cs)
	cs.owner = get_owner()
	cs.shape = mi.mesh.create_trimesh_shape()

	var tex_path := "res://addons/rennstrecke_plugin/resources/textures/%s.jpg" % preset_name
	if ResourceLoader.exists(tex_path):
		if mi.mesh and mi.mesh.get_surface_count() > 0:
			mi.mesh.surface_set_material(0, null)

		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1, 1, 1, 1)
		mat.albedo_texture = load(tex_path)
		mat.uv1_scale = Vector3(1, 1, 1)
		mat.metallic = 0.0
		mat.roughness = 1.0
		mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		mi.material_override = mat

func clear_contents() -> void:
	for n in get_children():
		if n is RoadPoint or n.name in ["TrackMesh", "TrackCollision"]:
			n.queue_free()
	print("CONTAINER[", track_id, "] ✓ contents cleared")
