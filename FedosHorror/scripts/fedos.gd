extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var player: CharacterBody3D = null
var current_speed: float = 2.0
var gravity: float = 9.8
var catch_distance: float = 1.8
var time_elapsed: float = 0.0
var breathing_intensity: float = 0.0
var detection_timer: float = 0.0
var is_active: bool = false
var aggro_pulse: float = 0.0

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
	breathing_intensity = sin(time_elapsed * 3.0) * 0.05
	aggro_pulse = sin(time_elapsed * 5.0) * 0.3 + 0.7

	if not is_on_floor():
		velocity.y -= gravity * delta

	var dist_to_player = global_position.distance_to(player.global_position)

	if dist_to_player < catch_distance:
		GameManager.lose_game()
		return

	nav_agent.target_position = player.global_position

	if nav_agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
	else:
		var next_pos = nav_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

	var look_target = player.global_position
	look_target.y = global_position.y
	if global_position.distance_to(look_target) > 0.1:
		var look_dir = (look_target - global_position).normalized()
		var target_angle = atan2(-look_dir.x, -look_dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 5.0)

	if mesh:
		mesh.scale = Vector3(1.0, 1.0 + breathing_intensity, 1.0)

	var eye_light = get_node_or_null("FedosEyeLight")
	if eye_light:
		eye_light.light_energy = 0.3 + aggro_pulse * 0.4

	var fedos_light = get_node_or_null("FedosLight")
	if fedos_light:
		fedos_light.light_energy = 0.5 + aggro_pulse * 0.3

	move_and_slide()
