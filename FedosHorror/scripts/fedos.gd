extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var body_mesh: MeshInstance3D = $Body
@onready var head_mesh: MeshInstance3D = $Head
@onready var left_arm: MeshInstance3D = $LeftArm
@onready var right_arm: MeshInstance3D = $RightArm

var player: CharacterBody3D = null
var current_speed: float = 2.0
var gravity: float = 9.8
var catch_distance: float = 2.0
var time_elapsed: float = 0.0
var detection_timer: float = 0.0
var is_active: bool = false
var path_update_timer: float = 0.0
var arm_swing_time: float = 0.0

func _ready():
	detection_timer = GameManager.get_detection_delay()
	await get_tree().create_timer(0.5).timeout
	player = get_tree().get_first_node_in_group("player")

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

	# Update path every 0.3s for performance
	path_update_timer -= delta
	if path_update_timer <= 0:
		nav_agent.target_position = player.global_position
		path_update_timer = 0.3

	if nav_agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
	else:
		var next_pos = nav_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

	# Face the player
	var look_target = player.global_position
	look_target.y = global_position.y
	if global_position.distance_to(look_target) > 0.1:
		var look_dir = (look_target - global_position).normalized()
		var target_angle = atan2(-look_dir.x, -look_dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 6.0)

	# Breathing/pulsing body
	var breathing = sin(time_elapsed * 3.0) * 0.04
	if body_mesh:
		body_mesh.scale = Vector3(1.0, 1.0 + breathing, 1.0)

	# Head tilt toward player (creepy)
	if head_mesh:
		var head_tilt = sin(time_elapsed * 2.0) * 0.1
		head_mesh.rotation.z = head_tilt

	# Arm swing animation when moving
	var speed_ratio = velocity.length() / max(current_speed, 0.1)
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

	# Pulsing eye light based on aggression
	var aggro = sin(time_elapsed * 5.0) * 0.3 + 0.7
	var eye_light = get_node_or_null("FedosEyeLight")
	if eye_light:
		eye_light.light_energy = 0.4 + aggro * 0.6

	var fedos_light = get_node_or_null("FedosLight")
	if fedos_light:
		fedos_light.light_energy = 0.6 + aggro * 0.5

	move_and_slide()
