@tool
extends Node3D
class_name RoadContainer

# Preload the mesh builder script
const TrackMeshBuilder = preload("res://addons/rennstrecke_plugin/mesh/TrackMeshBuilder.gd")

# Inspector properties
@export var track_id    : int               = 0        # Unique ID for this track
@export var profile     : ProfileResource            # Preset resource for width, banking, etc.
@export var bake_step   : float             = 0.05     # Curve bake interval (resolution of sampling)
@export var close_track : bool              = true     # Whether to close the track loop

# Internal preset name storage
var _preset_name: String = "race"
@export_enum("race","offroad","street")
var preset_name: String = "race":
	set(v):
		if _preset_name != v:
			_preset_name = v
			_apply_preset(v)   # Load corresponding .tres when changed
	get:
		return _preset_name

# The Path3D node where we bake our Curve3D
@onready var path: Path3D = Path3D.new()

func _ready() -> void:
	# Ensure Path3D child exists
	if not has_node("Path3D"):
		add_child(path)
	if path.curve == null:
		path.curve = Curve3D.new()
	_apply_preset(_preset_name)
	print("CONTAINER ready (track_id =", track_id, ")")

func _apply_preset(name: String) -> void:
	var res_path: String = "res://addons/rennstrecke_plugin/resources/presets/%s.tres" % name
	if ResourceLoader.exists(res_path):
		# Load the ProfileResource for width, banking, etc.
		profile = load(res_path)
		print("Applied preset:", name)
	else:
		push_warning("Preset not found: " + res_path)

func build_mesh(step: float = bake_step, close_track: bool = true) -> void:
	print("CONTAINER[", track_id, "] build_mesh(step =", step, ", closed =", close_track, ")")

	# 1) Collect RoadPoint positions
	var ctrl: Array[Vector3] = []
	for child in get_children():
		if child is RoadPoint:
			# Append each control point's local position
			ctrl.append(child.transform.origin)

	# 1b) Optionally close the loop by appending the first point again
	if close_track and ctrl.size() >= 2:
		ctrl.append(ctrl[0])

	if ctrl.size() < 2:
		push_warning("Too few points")
		return

	# 2) Fill the Curve3D and set Catmull–Rom tangents
	var curve: Curve3D = path.curve
	curve.clear_points()
	for p in ctrl:
		# Add control point to curve
		curve.add_point(p)
	var count: int = ctrl.size()
	for i in range(count):
		# Compute previous and next indices for smooth tangents
		var prev: Vector3 = ctrl[(i - 1 + count) % count]
		var next: Vector3 = ctrl[(i + 1)     % count]
		var tan: Vector3  = (next - prev) * 0.25
		curve.set_point_in(i,  -tan)   # In-tangent
		curve.set_point_out(i, tan)    # Out-tangent

	# 3) Bake curve and retrieve sampled points
	curve.bake_interval = step
	var pts: PackedVector3Array = curve.get_baked_points()
	var gap: float = pts[0].distance_to(pts[pts.size() - 1])
	print("build_mesh: ctrl=", ctrl.size(), "pts=", pts.size(), "gap=", gap)

	# 4) Remove previous mesh and collision
	if has_node("TrackMesh"):
		get_node("TrackMesh").queue_free()
	if has_node("TrackCollision"):
		get_node("TrackCollision").queue_free()

	# 5) Build new MeshInstance3D
	# Pass baked points and profile to the mesh builder
	var mi: MeshInstance3D = TrackMeshBuilder.build_mesh(pts, profile)
	add_child(mi)
	if get_owner():
		mi.owner = get_owner()

	# 6) Create StaticBody3D for collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.name             = "TrackCollision"
	sb.global_transform = mi.global_transform  # Match track mesh transform
	add_child(sb)
	if get_owner():
		sb.owner = get_owner()

	var cs: CollisionShape3D = CollisionShape3D.new()
	sb.add_child(cs)
	if get_owner():
		cs.owner = get_owner()
	# Generate a precise concave collision shape from mesh
	cs.shape = mi.mesh.create_trimesh_shape()

	# 7) Apply texture preset if available
	var tex_path: String = "res://addons/rennstrecke_plugin/resources/textures/%s.jpg" % _preset_name
	if ResourceLoader.exists(tex_path):
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_texture   = load(tex_path)
		mi.material_override = mat

func clear_contents() -> void:
	# Remove all RoadPoint, TrackMesh, and TrackCollision children
	for c in get_children():
		if c is RoadPoint or c.name.begins_with("Track"):
			c.queue_free()
	print("CONTAINER contents cleared for track_id =", track_id)
