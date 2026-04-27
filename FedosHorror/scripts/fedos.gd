extends CharacterBody3D

@onready var body_mesh: MeshInstance3D = $Body
@onready var head_mesh: MeshInstance3D = $FaceFront
@onready var left_arm: MeshInstance3D = $LeftArm
@onready var right_arm: MeshInstance3D = $RightArm

var player: CharacterBody3D = null
var current_speed: float = 2.0
var gravity: float = 9.8
var catch_distance: float = 2.0
var time_elapsed: float = 0.0
var detection_timer: float = 0.0
var is_active: bool = false
var arm_swing_time: float = 0.0
var stuck_timer: float = 0.0
var last_position: Vector3 = Vector3.ZERO
var wander_angle: float = 0.0

func _ready():
	detection_timer = GameManager.get_detection_delay()
	await get_tree().create_timer(0.5).timeout
	player = get_tree().get_first_node_in_group("player")
	last_position = global_position

func _physics_process(delta):
	if not GameManager.game_active:
		return
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	if not is_active:
		detection_timer -= delta
		if detection_timer <= 0:
			is_active = true
		else:
			return

	current_speed = GameManager.get_fedos_speed()
	time_elapsed += delta

	if not is_on_floor():
		velocity.y -= gravity * delta

	var dist_to_player = global_position.distance_to(player.global_position)

	if dist_to_player < catch_distance:
		GameManager.lose_game()
		return

	var dir_to_player = (player.global_position - global_position)
	dir_to_player.y = 0
	dir_to_player = dir_to_player.normalized()

	# Stuck detection: if barely moved in last 0.5s, add wander angle
	stuck_timer += delta
	if stuck_timer > 0.5:
		var moved = global_position.distance_to(last_position)
		if moved < 0.3:
			wander_angle += PI * 0.4
		else:
			wander_angle = move_toward(wander_angle, 0.0, delta * 3.0)
		last_position = global_position
		stuck_timer = 0.0

	# Apply wander offset if stuck
	if abs(wander_angle) > 0.1:
		var cos_a = cos(wander_angle)
		var sin_a = sin(wander_angle)
		dir_to_player = Vector3(
			dir_to_player.x * cos_a - dir_to_player.z * sin_a,
			0,
			dir_to_player.x * sin_a + dir_to_player.z * cos_a
		).normalized()

	velocity.x = dir_to_player.x * current_speed
	velocity.z = dir_to_player.z * current_speed

	# Face movement direction
	if dir_to_player.length() > 0.1:
		var target_angle = atan2(-dir_to_player.x, -dir_to_player.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 6.0)

	# Breathing/pulsing body
	var breathing = sin(time_elapsed * 3.0) * 0.04
	if body_mesh:
		body_mesh.scale = Vector3(1.0, 1.0 + breathing, 1.0)

	# Head tilt (creepy)
	if head_mesh:
		head_mesh.rotation.z = sin(time_elapsed * 2.0) * 0.1

	# Arm swing when moving
	var speed_ratio = Vector2(velocity.x, velocity.z).length() / max(current_speed, 0.1)
	if speed_ratio > 0.2:
		arm_swing_time += delta * current_speed * 2.0
		var swing = sin(arm_swing_time) * 0.6
		if left_arm:
			left_arm.rotation.x = -0.5 + swing
		if right_arm:
			right_arm.rotation.x = -0.5 - swing
	else:
		if left_arm:
			left_arm.rotation.x = lerp(left_arm.rotation.x, -0.3, delta * 3.0)
		if right_arm:
			right_arm.rotation.x = lerp(right_arm.rotation.x, -0.3, delta * 3.0)

	# Pulsing lights
	var aggro = sin(time_elapsed * 5.0) * 0.3 + 0.7
	var eye_light = get_node_or_null("FedosEyeLight")
	if eye_light:
		eye_light.light_energy = 0.4 + aggro * 0.6
	var fedos_light = get_node_or_null("FedosLight")
	if fedos_light:
		fedos_light.light_energy = 0.6 + aggro * 0.5

	move_and_slide()
