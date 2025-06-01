@tool
extends Node3D

const MeshBuilder = preload("res://scripts/core/TrackMeshBuilder.gd")

func _enter_tree():
	print("TrackBuilder: _enter_tree() aufgerufen")

func _ready():
	print("TrackBuilder: _ready() aufgerufen")

func build(params: Dictionary, scene_root: Node) -> void:
	print("TrackBuilder: build() gestartet")
	print("TrackBuilder: Parameter erhalten:", params)

	if not scene_root:
		push_error("TrackBuilder: scene_root ist null!")
		return

	if not scene_root.has_node("CurveHandler"):
		push_error("TrackBuilder: CurveHandler-Node NICHT gefunden!")
		return
	var handler = scene_root.get_node("CurveHandler")
	print("TrackBuilder: CurveHandler gefunden:", handler.name)

	var points = handler.get_baked_points()
	print("TrackBuilder: Anzahl gebacketer Punkte:", points.size())
	for i in range(points.size()):
		print("  Punkt[", i, "] =", points[i])

	var mb = MeshBuilder.new()
	if not mb:
		push_error("TrackBuilder: Konnte TrackMeshBuilder NICHT instanziieren!")
		return
	print("TrackBuilder: TrackMeshBuilder-Instanz erstellt:", mb)

	scene_root.add_child(mb)
	print("TrackBuilder: TrackMeshBuilder ans Scene-Root gehängt. Szene-Children:")
	for child in scene_root.get_children():
		print("  -", child.name)

	print("TrackBuilder: Rufe mb.build(params, points) auf …")
	mb.build(params, points)
	print("TrackBuilder: mb.build() abgeschlossen")
