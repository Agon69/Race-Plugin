@tool
extends Node3D
class_name RoadManager

@export var generate_track: bool = false : set = _on_generate_track

func _on_generate_track(v: bool) -> void:
	if v:
		print("MANAGER ✓ generate_track toggled")
		rebuild_all()
		generate_track = false

func rebuild_all() -> void:
	print("MANAGER → rebuild_all()")
	for child in get_children():
		print("MANAGER   • found:", child)
		if child is RoadContainer:
			child.build_mesh(0.2)
