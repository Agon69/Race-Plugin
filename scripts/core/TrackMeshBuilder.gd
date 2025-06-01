@tool
extends Node3D

func build(params: Dictionary, points: PackedVector3Array) -> void:
	print("TrackMeshBuilder got params:", params, "and points:", points.size())
	# … hier kommt deine Extrusionslogik
