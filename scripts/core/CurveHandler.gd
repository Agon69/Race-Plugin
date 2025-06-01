@tool
extends Node3D

@onready var path = $"../CurvePath"

func _enter_tree():
	print("CurveHandler: _enter_tree() aufgerufen")

func _ready():
	print("CurveHandler: _ready() aufgerufen")
	if not path.curve:
		path.curve = Curve3D.new()
	print("CurveHandler: path.curve bereit")

func add_point(pos: Vector3) -> void:
	print("CurveHandler: add_point() mit", pos)
	path.curve.add_point(pos)

func clear_points() -> void:
	print("CurveHandler: clear_points() aufgerufen")
	path.curve.clear_points()

func get_baked_points() -> PackedVector3Array:
	print("CurveHandler: get_baked_points() aufgerufen")
	return path.curve.get_baked_points()
