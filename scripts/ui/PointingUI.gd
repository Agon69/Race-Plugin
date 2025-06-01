extends Control

@onready var btn_clear = $VBoxContainer/ClearPoints

signal clear_requested

func _enter_tree():
	print("PointingUI: _enter_tree() aufgerufen")

func _ready():
	print("PointingUI: _ready() aufgerufen")
	btn_clear.pressed.connect(_on_clear_pressed)

func _on_clear_pressed():
	print("PointingUI: ClearPoints gedrückt, sende clear_requested")
	emit_signal("clear_requested")
