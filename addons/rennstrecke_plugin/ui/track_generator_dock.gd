@tool
extends VBoxContainer

const TrackBuilderScene = preload("res://scripts/core/TrackBuilder.gd")

@onready var length_spin   = $Streckenlaenge
@onready var curve_spin    = $Kurvenanzahl
@onready var width_spin    = $Breite
@onready var banking_spin  = $Banking
@onready var elev_spin     = $Hoehenprofil
@onready var gen_button    = $Generieren

func _ready():
	gen_button.pressed.connect(_on_generate_pressed)

func _on_generate_pressed():
	var params = {
		"length":    length_spin.value,
		"curves":    curve_spin.value,
		"width":     width_spin.value,
		"banking":   banking_spin.value,
		"elevation": elev_spin.value
	}
	print("Parameters:", params)

	# Instanz erstellen und build() aufrufen
	var builder = TrackBuilderScene.new()
	# du kannst ihn ans Plugin oder an die Szene hängen, falls nötig:
	get_tree().get_current_scene().add_child(builder)
	builder.build(params, get_tree().get_current_scene())
