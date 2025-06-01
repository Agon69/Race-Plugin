extends Resource
class_name ProfileResource

@export var width: float   = 2.0
@export var height: float  = 0.1
@export var banking: float = 0.0

func _init():
	print("ProfileResource: init() mit width=", width, " height=", height, " banking=", banking)
