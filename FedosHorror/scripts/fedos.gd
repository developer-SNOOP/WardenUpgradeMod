extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var player: CharacterBody3D = null
var current_speed: float = 2.0
var gravity: float = 9.8
var wander_timer: float = 0.0
var wander_target: Vector3 = Vector3.ZERO
var is_chasing: bool = false
var detection_range: float = 50.0
var catch_distance: float = 1.8
var time_elapsed: float = 0.0
var breathing_intensity: float = 0.0

func _ready():
	await get_tree().create_timer(0.5).timeout
	player = get_tree().get_first_node_in_group("player")
	_pick_wander_target()

func _physics_process(delta):
	if not GameManager.game_active:
		return
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	current_speed = GameManager.get_fedos_speed()

	time_elapsed += delta
	breathing_intensity = sin(time_elapsed * 3.0) * 0.05

	if not is_on_floor():
		velocity.y -= gravity * delta

	var dist_to_player = global_position.distance_to(player.global_position)

	if dist_to_player < catch_distance:
		GameManager.lose_game()
		return

	is_chasing = true
	nav_agent.target_position = player.global_position

	if nav_agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
	else:
		var next_pos = nav_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

	# Fedos looks at player
	var look_target = player.global_position
	look_target.y = global_position.y
	if global_position.distance_to(look_target) > 0.1:
		var look_dir = (look_target - global_position).normalized()
		var target_angle = atan2(-look_dir.x, -look_dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 5.0)

	# Breathing animation on mesh
	if mesh:
		mesh.scale = Vector3(1.0, 1.0 + breathing_intensity, 1.0)

	move_and_slide()

func _pick_wander_target():
	wander_target = global_position + Vector3(randf_range(-8, 8), 0, randf_range(-8, 8))
