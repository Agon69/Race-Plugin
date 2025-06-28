@tool
extends Node3D
class_name RoadManager

var _next_track_id: int = 1    # fortlaufender Zähler

# ------------------------------------------------------------
#   Inspector-Schalter
# ------------------------------------------------------------
@export var generate_track: bool = false:
	set(value):
		if value:
			_rebuild_all()
			generate_track = false          # Checkbox zurücksetzen
			
@export var track_is_closed: bool = true  # ⬅️ Standard: geschlossen


@export var delete_track_id: int = 0        # ID eintragen

@export var confirm_delete: bool = false:
	set(value):
		if value:
			_delete_contents_by_id(delete_track_id)
			confirm_delete   = false        # Checkbox zurücksetzen
			delete_track_id = 0             # Feld leeren

# ------------------------------------------------------------
#   Strecken (re)generieren
# ------------------------------------------------------------
func _rebuild_all() -> void:
	for child in get_children():
		if child is RoadContainer:
			if child.track_id == 0:               # neue ID
				child.track_id = _next_track_id
				_next_track_id += 1
			child.build_mesh(child.bake_step, track_is_closed)


# ------------------------------------------------------------
#   Inhalte per ID löschen
# ------------------------------------------------------------
func _delete_contents_by_id(id: int) -> void:
	if id <= 0:
		push_warning("Ungültige Track-ID!")
		return
	for child in get_children():
		if child is RoadContainer and child.track_id == id:
			child.clear_contents()
			print("MANAGER ✓ cleared track", id)
			return
	push_warning("Track-ID %d nicht gefunden." % id)
