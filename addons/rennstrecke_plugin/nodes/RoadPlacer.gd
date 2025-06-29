@tool
extends Node3D
class_name RoadPlacer

var was_pressed_last_frame: bool = false

func _process(_delta: float) -> void:
	# Only run in the editor, not at runtime
	if not Engine.is_editor_hint():
		return

	# Check for P key press to place a RoadPoint
	if Input.is_key_pressed(KEY_P):
		if not was_pressed_last_frame:
			_place_point_at_mouse()
		was_pressed_last_frame = true
	else:
		was_pressed_last_frame = false

func _place_point_at_mouse() -> void:
	# Get the current editor camera
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		push_error("No camera found")
		return

	# Cast a ray from the mouse cursor into the 3D world
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * 1000.0

	# Perform the raycast against physics bodies
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result: Dictionary = space_state.intersect_ray(query)

	# If nothing was hit, abort placement
	if result.is_empty():
		print("No collision hit; cannot place point")
		return

	# Use the hit position for the new RoadPoint
	var pos: Vector3 = result.position

	# Find the RoadContainer in the current edited scene
	var scene_root: Node = get_tree().edited_scene_root
	if scene_root == null:
		push_error("No scene open")
		return
	var road_container: Node3D = scene_root.find_child("RoadContainer", true, false)
	if road_container == null:
		push_error("RoadContainer not found")
		return

	# Instantiate a new RoadPoint and ensure a unique name
	var roadpoint: Node3D = preload("res://addons/rennstrecke_plugin/nodes/RoadPoint.gd").new()
	var base_name: String = "RoadPoint"
	var index: int = 0
	var unique_name: String = base_name
	while road_container.has_node(unique_name):
		index += 1
		unique_name = base_name + str(index)

	# Set up the RoadPoint and add it under the RoadContainer
	roadpoint.name = unique_name
	roadpoint.position = pos
	road_container.add_child(roadpoint)
	roadpoint.owner = scene_root

	# Debug output to the console
	print("Placed", roadpoint.name, "at", pos)
