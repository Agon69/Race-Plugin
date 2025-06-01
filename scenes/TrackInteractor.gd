extends Node3D

var ui: Node = null
var points: PackedVector3Array = PackedVector3Array()

func _enter_tree():
	print("TrackInteractor: _enter_tree() aufgerufen")

func _ready():
	print("TrackInteractor: _ready() aufgerufen")
	ui = get_node("../UI/PointingUI")
	if not ui:
		push_error("TrackInteractor: Konnte '../UI/PointingUI' nicht finden!")
		return

	ui.connect("clear_requested", Callable(self, "_on_clear_requested"))
	set_process_input(true)
	print("TrackInteractor: UI verbunden und Input aktiviert")

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var camera = get_node("../Camera3D")
		var from = camera.project_ray_origin(event.position)
		var to   = from + camera.project_ray_normal(event.position) * 1000.0

		var ray_params = PhysicsRayQueryParameters3D.new()
		ray_params.from = from
		ray_params.to   = to

		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(ray_params)

		if result:
			_add_point(result.position)
		else:
			print("TrackInteractor: Raycast trifft nichts!")

func _add_point(pos: Vector3):
	points.append(pos)
	print("TrackInteractor: _add_point() mit", pos)
	var sphere = SphereMesh.new()
	var mi = MeshInstance3D.new()
	mi.mesh = sphere
	mi.transform.origin = pos
	mi.scale = Vector3.ONE * 0.2
	add_child(mi)

	var curve_handler = get_node("../CurveHandler")
	if curve_handler:
		curve_handler.add_point(pos)
		print("TrackInteractor: Punkt an CurveHandler übergeben:", pos)
	else:
		push_error("TrackInteractor: CurveHandler nicht gefunden!")

func _on_clear_requested():
	points.clear()
	for child in get_children():
		if child is MeshInstance3D and child.mesh is SphereMesh:
			child.queue_free()
	print("TrackInteractor: Alle Punkte und Kugeln gelöscht")
