@tool
extends Node3D
class_name RoadManager

# Counter for assigning unique track IDs
var _next_track_id: int = 1

# ------------------------------------------------------------
#   Inspector Controls
# ------------------------------------------------------------

# Toggle to trigger track mesh generation in editor
@export var generate_track: bool = false:
	set(value):
		if value:
			_rebuild_all()          # Regenerate all tracks
			generate_track = false  # Reset checkbox

# Toggle whether tracks should be closed loops
@export var track_is_closed: bool = true

# Deletion controls: specify ID and confirm
@export var delete_track_id: int = 0

# Trigger to delete a specific track by ID
@export var confirm_delete: bool = false:
	set(value):
		if value:
			_delete_contents_by_id(delete_track_id)
			confirm_delete   = false  # Reset checkbox
			delete_track_id = 0       # Clear ID field

# ------------------------------------------------------------
#   Rebuild All Tracks
# ------------------------------------------------------------

# Iterate through all RoadContainers and regenerate mesh
func _rebuild_all() -> void:
	for child in get_children():
		if child is RoadContainer:
			# Assign new ID if needed
			if child.track_id == 0:
				child.track_id = _next_track_id
				_next_track_id += 1
			# Generate track mesh with closure option
			child.build_mesh(child.bake_step, track_is_closed)

# ------------------------------------------------------------
#   Delete Track Contents by ID
# ------------------------------------------------------------

# Clears RoadPoints and mesh for a given track ID
func _delete_contents_by_id(id: int) -> void:
	if id <= 0:
		push_warning("Invalid Track ID!")
		return
	for child in get_children():
		if child is RoadContainer and child.track_id == id:
			child.clear_contents()
			print("MANAGER ✓ cleared track", id)
			return
	push_warning("Track ID %d not found." % id)
