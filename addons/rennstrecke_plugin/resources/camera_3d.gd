extends Camera3D

@export var move_speed := 5.0
@export var sprint_speed := 10.0
@export var mouse_sensitivity := 0.3

var rotation_x := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -90, 90)
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.x = rotation_x

func _physics_process(delta):
	var speed := move_speed
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed

	var direction := Vector3.ZERO
	if Input.is_action_pressed("forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("back"):
		direction += transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("right"):
		direction += transform.basis.x
	if Input.is_action_pressed("up"):
		direction += transform.basis.y
	if Input.is_action_pressed("down"):
		direction -= transform.basis.y

	translate(direction.normalized() * speed * delta)
