@tool
extends Node

const MeshBuilder = preload("res://scripts/core/TrackMeshBuilder.gd")

func build(params: Dictionary, scene_root: Node) -> void:
	print("TrackBuilder got params:", params)
	var handler = scene_root.get_node("CurveHandler") if scene_root.has_node("CurveHandler") else null
	if not handler:
		push_error("CurveHandler-Node nicht gefunden!")
		return

	var points = handler.get_baked_points()  # liefert jetzt PackedVector3Array
	var mesh_builder = MeshBuilder.new()
	scene_root.add_child(mesh_builder)
	mesh_builder.build(params, points)
