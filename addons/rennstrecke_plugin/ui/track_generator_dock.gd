# res://addons/rennstrecke_plugin/ui/track_generator_dock.gd
@tool
extends VBoxContainer

const TrackBuilderScene = preload("res://scripts/core/TrackBuilder.gd")

@onready var length_spin   = $Streckenlaenge
@onready var curve_spin    = $Kurvenanzahl
@onready var width_spin    = $Breite
@onready var banking_spin  = $Banking
@onready var elev_spin     = $Hoehenprofil
@onready var gen_button    = $Generieren

func _enter_tree():
	print("TrackGeneratorDock: _enter_tree() aufgerufen")

func _ready():
	print("TrackGeneratorDock: _ready() aufgerufen")
	gen_button.pressed.connect(_on_generate_pressed)

func _on_generate_pressed():
	print("TrackGeneratorDock: Generieren-Button gedrückt")

	# 1) Parameter auslesen
	var params = {
		"length":    length_spin.value,
		"curves":    curve_spin.value,
		"width":     width_spin.value,
		"banking":   banking_spin.value,
		"elevation": elev_spin.value
	}
	print("TrackGeneratorDock: Geladene Parameter:", params)

	# 2) Im Editor die aktuell geöffnete Szene holen
	var current_scene = get_tree().edited_scene_root
	if not current_scene:
		push_error("TrackGeneratorDock: Im Editor ist keine Szene zum Bearbeiten geöffnet!")
		return
	print("TrackGeneratorDock: Bearbeitete Szene im Editor:", current_scene.name)

	# 3) TrackBuilder instanziieren
	var builder = TrackBuilderScene.new()
	if not builder:
		push_error("TrackGeneratorDock: Konnte TrackBuilder NICHT instanziieren!")
		return
	print("TrackGeneratorDock: TrackBuilder-Instanz erstellt:", builder)

	# 4) Builder dem Editor‐Root hinzufügen
	current_scene.add_child(builder)
	print("TrackGeneratorDock: TrackBuilder als Child hinzugefügt. Szene‐Children:")
	for child in current_scene.get_children():
		print("  -", child.name)

	# 5) build() aufrufen
	print("TrackGeneratorDock: Rufe builder.build(params, current_scene) auf …")
	builder.build(params, current_scene)
	print("TrackGeneratorDock: builder.build() zurückgekehrt")
