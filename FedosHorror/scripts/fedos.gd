extends CharacterBody3D

@onready var body_mesh: MeshInstance3D = $Body
@onready var head_mesh: MeshInstance3D = $Head
@onready var face_front: MeshInstance3D = $FaceFront
@onready var left_arm: MeshInstance3D = $LeftArm
@onready var right_arm: MeshInstance3D = $RightArm
@onready var left_leg: MeshInstance3D = $LeftLeg
@onready var right_leg: MeshInstance3D = $RightLeg

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
var voice_timer: float = 0.0
var next_voice_time: float = 8.0
var voice_player: AudioStreamPlayer3D = null
var voice_lines: Array = []

# Toilet cabin spawn
var spawn_delay: float = 3.0
var has_spawned: bool = false
var toilet_door: MeshInstance3D = null

func _ready():
	_setup_voice()
	detection_timer = GameManager.get_detection_delay()
	visible = false
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

	# Toilet spawn animation
	if not has_spawned:
		spawn_delay -= delta
		if spawn_delay <= 0:
			has_spawned = true
			visible = true
			if toilet_door:
				var tween = create_tween()
				tween.tween_property(toilet_door, "rotation:y", -PI * 0.5, 1.0)
		return

	if not is_active:
		detection_timer -= delta
		if detection_timer <= 0:
			is_active = true
		else:
			return

	current_speed = GameManager.get_fedos_speed()
	time_elapsed += delta

	# Voice line playback
	voice_timer += delta
	if voice_timer >= next_voice_time and voice_player and not voice_player.playing:
		_play_random_voice()
		voice_timer = 0.0
		next_voice_time = randf_range(6.0, 15.0)

	if not is_on_floor():
		velocity.y -= gravity * delta

	# Check if player is hidden
	var game_ui = _get_game_ui()
	if game_ui and game_ui.is_hiding:
		if game_ui.hold_breath_active:
			# Player hiding + holding breath = Fedos wanders
			_do_wander(delta)
			move_and_slide()
			return
		else:
			# Player hiding but not holding breath - 50% chance Fedos detects
			var dist_to_player = global_position.distance_to(player.global_position)
			if dist_to_player < 8.0 and randf() < 0.003:
				game_ui.force_exit_locker()

	var dist_to_player = global_position.distance_to(player.global_position)

	if dist_to_player < catch_distance:
		GameManager.lose_game()
		return

	var dir_to_player = (player.global_position - global_position)
	dir_to_player.y = 0
	dir_to_player = dir_to_player.normalized()

	# Stuck detection
	stuck_timer += delta
	if stuck_timer > 0.5:
		var moved = global_position.distance_to(last_position)
		if moved < 0.3:
			wander_angle = min(wander_angle + PI * 0.4, PI)
		else:
			wander_angle = move_toward(wander_angle, 0.0, 0.5 * 3.0)
		last_position = global_position
		stuck_timer = 0.0

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

	_animate_body(delta)
	move_and_slide()

func _do_wander(delta):
	time_elapsed += delta
	var wander_dir = Vector3(sin(time_elapsed * 0.5), 0, cos(time_elapsed * 0.7)).normalized()
	velocity.x = wander_dir.x * current_speed * 0.4
	velocity.z = wander_dir.z * current_speed * 0.4
	_animate_body(delta)

func _animate_body(delta):
	# Breathing/pulsing torso
	var breathing = sin(time_elapsed * 3.0) * 0.03
	if body_mesh:
		body_mesh.scale = Vector3(1.0, 1.0 + breathing, 1.0)

	# Head tilt (creepy)
	if head_mesh:
		head_mesh.rotation.z = sin(time_elapsed * 2.0) * 0.12
		head_mesh.rotation.x = sin(time_elapsed * 1.5) * 0.05
	if face_front:
		face_front.rotation.z = sin(time_elapsed * 2.0) * 0.12

	# Limb animation
	var speed_ratio = Vector2(velocity.x, velocity.z).length() / max(current_speed, 0.1)
	if speed_ratio > 0.2:
		arm_swing_time += delta * current_speed * 2.0
		var swing = sin(arm_swing_time) * 0.5
		if left_arm:
			left_arm.rotation.x = -0.4 + swing
		if right_arm:
			right_arm.rotation.x = -0.4 - swing
		# Leg animation - walk cycle
		if left_leg:
			left_leg.rotation.x = sin(arm_swing_time) * 0.4
		if right_leg:
			right_leg.rotation.x = -sin(arm_swing_time) * 0.4
	else:
		if left_arm:
			left_arm.rotation.x = lerp(left_arm.rotation.x, -0.2, delta * 3.0)
		if right_arm:
			right_arm.rotation.x = lerp(right_arm.rotation.x, -0.2, delta * 3.0)
		if left_leg:
			left_leg.rotation.x = lerp(left_leg.rotation.x, 0.0, delta * 3.0)
		if right_leg:
			right_leg.rotation.x = lerp(right_leg.rotation.x, 0.0, delta * 3.0)

	# Pulsing lights
	var aggro = sin(time_elapsed * 5.0) * 0.3 + 0.7
	var eye_light = get_node_or_null("FedosEyeLight")
	if eye_light:
		eye_light.light_energy = 0.4 + aggro * 0.6
	var fedos_light = get_node_or_null("FedosLight")
	if fedos_light:
		fedos_light.light_energy = 0.6 + aggro * 0.5

func _get_game_ui():
	var game = get_tree().current_scene
	if game:
		return game.get_node_or_null("GameUI")
	return null

func _setup_voice():
	voice_player = AudioStreamPlayer3D.new()
	voice_player.max_db = 10.0
	voice_player.unit_size = 15.0
	voice_player.max_distance = 50.0
	voice_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	add_child(voice_player)
	for i in range(1, 5):
		var path = "res://audio/fedos_voice%d.ogg" % i
		var stream = load(path)
		if stream:
			voice_lines.append(stream)

func _play_random_voice():
	if voice_lines.size() == 0:
		return
	var idx = randi() % voice_lines.size()
	voice_player.stream = voice_lines[idx]
	voice_player.pitch_scale = randf_range(0.85, 1.1)
	voice_player.play()
