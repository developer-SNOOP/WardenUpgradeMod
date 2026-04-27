extends CharacterBody3D

const MOUSE_SENSITIVITY_BASE = 0.003
const TOUCH_LOOK_SENSITIVITY_BASE = 0.004

@onready var camera: Camera3D = $Camera3D
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight

var touch_look_start: Vector2 = Vector2.ZERO
var touch_move_start: Vector2 = Vector2.ZERO
var touch_look_index: int = -1
var touch_move_index: int = -1
var move_vec: Vector2 = Vector2.ZERO
var camera_rotation_x: float = 0.0
var is_sprinting: bool = false
var head_bob_time: float = 0.0
var stamina: float = 100.0
var max_stamina: float = 100.0
var stamina_drain: float = 20.0
var stamina_regen: float = 15.0
var joystick_move_vec: Vector2 = Vector2.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	flashlight.spot_range = GameManager.get_flashlight_range()

func _unhandled_input(event):
	if not GameManager.game_active:
		return

	var sensitivity = GameManager.look_sensitivity

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY_BASE * sensitivity)
		camera_rotation_x -= event.relative.y * MOUSE_SENSITIVITY_BASE * sensitivity
		camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
		camera.rotation.x = camera_rotation_x

	if event is InputEventScreenTouch:
		var screen_w = get_viewport().get_visible_rect().size.x
		if event.pressed:
			if event.position.x > screen_w * 0.5:
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
			rotate_y(-delta.x * TOUCH_LOOK_SENSITIVITY_BASE * sensitivity)
			camera_rotation_x -= delta.y * TOUCH_LOOK_SENSITIVITY_BASE * sensitivity
			camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
			camera.rotation.x = camera_rotation_x
		elif event.index == touch_move_index:
			var diff = event.position - touch_move_start
			move_vec = diff.normalized() * min(diff.length() / 80.0, 1.0)

func set_joystick_input(vec: Vector2):
	joystick_move_vec = vec

func _physics_process(delta):
	if not GameManager.game_active:
		velocity = Vector3.ZERO
		return

	if not is_on_floor():
		velocity.y -= 9.8 * delta

	is_sprinting = Input.is_action_pressed("sprint") and stamina > 0
	if is_sprinting:
		stamina = max(0, stamina - stamina_drain * delta)
	else:
		stamina = min(max_stamina, stamina + stamina_regen * delta)

	var base_speed = GameManager.get_player_speed()
	var sprint_speed = GameManager.get_sprint_speed()
	var current_speed = sprint_speed if is_sprinting else base_speed

	var input_dir = Vector2.ZERO
	if joystick_move_vec.length() > 0.1:
		input_dir = joystick_move_vec
	elif touch_move_index >= 0:
		input_dir = move_vec
	else:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * delta * 8.0)
		velocity.z = move_toward(velocity.z, 0, current_speed * delta * 8.0)

	if GameManager.head_bob_enabled and direction and is_on_floor():
		var bob_freq = 14.0 if is_sprinting else 10.0
		var bob_amp = 0.04 if is_sprinting else 0.025
		head_bob_time += delta * bob_freq
		camera.position.y = 0.7 + sin(head_bob_time) * bob_amp
	else:
		camera.position.y = lerp(camera.position.y, 0.7, delta * 10.0)

	move_and_slide()
