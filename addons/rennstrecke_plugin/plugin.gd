@tool
extends EditorPlugin

func _enter_tree() -> void:
	print("RennstreckePlugin ist geladen")
	add_custom_type(
		"RoadManager",
		"Node3D",
		preload("nodes/RoadManager.gd"),
		null              # oder preload("icons/manager.svg")
	)
	add_custom_type(
		"RoadContainer",
		"Node3D",
		preload("nodes/RoadContainer.gd"),
		null
	)
	add_custom_type(
		"RoadPoint",
		"Node3D",
		preload("nodes/RoadPoint.gd"),
		null
	)

func _exit_tree() -> void:
	remove_custom_type("RoadManager")
	remove_custom_type("RoadContainer")
	remove_custom_type("RoadPoint")
