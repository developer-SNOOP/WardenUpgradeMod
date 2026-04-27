extends CharacterBody3D

const SPEED = 4.0
const MOUSE_SENSITIVITY = 0.003
const TOUCH_LOOK_SENSITIVITY = 0.005

@onready var camera: Camera3D = $Camera3D
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight

var touch_look_start: Vector2 = Vector2.ZERO
var touch_move_start: Vector2 = Vector2.ZERO
var touch_look_index: int = -1
var touch_move_index: int = -1
var move_vec: Vector2 = Vector2.ZERO
var camera_rotation_x: float = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if not GameManager.game_active:
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_rotation_x -= event.relative.y * MOUSE_SENSITIVITY
		camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
		camera.rotation.x = camera_rotation_x

	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x > get_viewport().get_visible_rect().size.x * 0.5:
				touch_look_index = event.index
				touch_look_start = event.position
			else:
				touch_move_index = event.index
				touch_move_start = event.position
		else:
			if event.index == touch_look_index:
				touch_look_index = -1
			elif event.index == touch_move_index:
				touch_move_index = -1
				move_vec = Vector2.ZERO

	if event is InputEventScreenDrag:
		if event.index == touch_look_index:
			var delta = event.relative
			rotate_y(-delta.x * TOUCH_LOOK_SENSITIVITY)
			camera_rotation_x -= delta.y * TOUCH_LOOK_SENSITIVITY
			camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
			camera.rotation.x = camera_rotation_x
		elif event.index == touch_move_index:
			var diff = event.position - touch_move_start
			move_vec = diff.normalized() * min(diff.length() / 80.0, 1.0)

func _physics_process(delta):
	if not GameManager.game_active:
		velocity = Vector3.ZERO
		return

	if not is_on_floor():
		velocity.y -= 9.8 * delta

	var input_dir = Vector2.ZERO

	if touch_move_index >= 0:
		input_dir = move_vec
	else:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 8.0)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta * 8.0)

	move_and_slide()
