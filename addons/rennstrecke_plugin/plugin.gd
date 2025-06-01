@tool
extends EditorPlugin

var dock_instance

func _enter_tree():
	print("Plugin.gd: _enter_tree() aufgerufen")
	var dock_scene = preload("res://addons/rennstrecke_plugin/ui/track_generator_dock.tscn")
	dock_instance = dock_scene.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock_instance)
	print("Plugin.gd: Dock-Instanz erzeugt und hinzugefügt")

func _exit_tree():
	print("Plugin.gd: _exit_tree() aufgerufen")
	if dock_instance:
		remove_control_from_docks(dock_instance)
		dock_instance = null
	print("Plugin.gd: Dock entfernt")
