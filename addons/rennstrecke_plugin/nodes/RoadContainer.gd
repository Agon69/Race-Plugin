# res://addons/rennstrecke_plugin/nodes/RoadContainer.gd
@tool
extends Node3D
class_name RoadContainer

@export var profile   : ProfileResource
@export var bake_step : float = 0.05

@onready var path: Path3D = Path3D.new()

func _ready() -> void:
	if not has_node("Path3D"):
		add_child(path)
	if not path.curve:
		path.curve = Curve3D.new()
	print("CONTAINER ✓ ready")

func build_mesh(step: float = bake_step) -> void:
	print("CONTAINER → build_mesh(step =", step, ")")

	# 1) Sammle Kontroll-Punkte
	var ctrl: Array[Vector3] = []
	for c in get_children():
		if c is RoadPoint:
			ctrl.append(c.global_transform.origin)
			print("  • RoadPoint:", c.global_transform.origin)
	if ctrl.size() < 2:
		push_warning("⚠️ Zu wenig Punkte!")
		return

	# 2) Curve neu aufbauen
	var curve := path.curve
	curve.clear_points()
	for p in ctrl:
		curve.add_point(p)
	# 2b) Catmull-Tangenten manuell setzen
	for i in range(ctrl.size()):
		var in_t:  Vector3 = Vector3.ZERO
		var out_t: Vector3 = Vector3.ZERO
		if i > 0 and i < ctrl.size() - 1:
			var prev = ctrl[i - 1]
			var next = ctrl[i + 1]
			var tan  = (next - prev) * 0.25
			in_t  = -tan
			out_t =  tan
		curve.set_point_in(i,  in_t)
		curve.set_point_out(i, out_t)
		print("    - tangent[", i, "] in=", in_t, " out=", out_t)

	# 3) Punkte backen & debug-print
	curve.bake_interval = step
	var pts: PackedVector3Array = curve.get_baked_points()
	print("   → baked pts.size =", pts.size())
	# Druck ein paar Stichproben, um den X-Offset zu sehen:
	for i in [0, int(pts.size() * 0.25), int(pts.size() * 0.5), pts.size() - 1]:
		print("      * sample pt[", i, "]=", pts[i])

	# 4) altes Mesh entfernen
	if has_node("TrackMesh"):
		get_node("TrackMesh").queue_free()
		print("   • old TrackMesh freed")

	# 5) neues bauen + anhängen
	var mi: MeshInstance3D = TrackMeshBuilder.build_mesh(pts, profile)
	add_child(mi)
	mi.owner = get_owner()
	print("CONTAINER ✓ attached TrackMesh:", mi)
