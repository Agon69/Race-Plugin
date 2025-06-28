@tool
extends Node3D
class_name RoadPlacer

var was_pressed_last_frame: bool = false

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return

	# Tastendruck prüfen: Taste P
	if Input.is_key_pressed(KEY_P):
		if not was_pressed_last_frame:
			_place_point_at_mouse()
		was_pressed_last_frame = true
	else:
		was_pressed_last_frame = false

func _place_point_at_mouse() -> void:
	print("📦 Platzierung ausgelöst durch Taste P")  # Debug

	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		push_error("❌ Keine Kamera gefunden")
		return

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * 1000.0

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result: Dictionary = space_state.intersect_ray(query)

	if result.is_empty():
		print("⚠️ Kein Treffer im Raum")
		return

	var pos: Vector3 = result.position

	var scene_root: Node = get_tree().edited_scene_root
	if scene_root == null:
		push_error("❌ Keine Szene geöffnet!")
		return

	var road_container: Node3D = scene_root.find_child("RoadContainer", true, false)
	if road_container == null:
		push_error("❌ RoadContainer nicht gefunden!")
		return

	var roadpoint: Node3D = preload("res://addons/rennstrecke_plugin/nodes/RoadPoint.gd").new()
	var base_name: String = "RoadPoint"
	var index: int = 0
	var unique_name: String = base_name

	while road_container.has_node(unique_name):
		index += 1
		unique_name = base_name + str(index)

	roadpoint.name = unique_name
	roadpoint.position = pos
	road_container.add_child(roadpoint)
	roadpoint.owner = scene_root

	print("✅", roadpoint.name, "platziert bei:", pos)
