@tool
extends Object
class_name UVUtils

static func set_uv(st: SurfaceTool, u: float, v: float) -> void:
	st.set_uv(Vector2(u, v))
