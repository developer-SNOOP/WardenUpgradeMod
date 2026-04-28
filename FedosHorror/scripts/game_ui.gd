extends CanvasLayer

@onready var apple_label: Label = $AppleCounter
@onready var speed_warning: Label = $SpeedWarning
@onready var win_panel: Panel = $WinPanel
@onready var lose_panel: Panel = $LosePanel
@onready var vignette: ColorRect = $Vignette
@onready var fps_label: Label = $FPSLabel
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var sprint_label: Label = $SprintLabel
@onready var joystick: Control = $VirtualJoystick
@onready var difficulty_label: Label = $DifficultyLabel
@onready var heartbeat_label: Label = $HeartbeatLabel
@onready var flashlight_label: Label = $FlashlightLabel
@onready var sprint_button: Label = $SprintButton
@onready var screamer_rect: ColorRect = $ScreamerRect
@onready var screamer_image: TextureRect = $ScreamerRect/ScreamerImage
@onready var battery_bar: ProgressBar = $BatteryBar
@onready var battery_label: Label = $BatteryLabel

var warning_timer: float = 0.0
var shake_amount: float = 0.0
var heartbeat_time: float = 0.0
var is_sprinting_touch: bool = false
var flashlight_touch_area: Rect2 = Rect2()
var sprint_touch_area: Rect2 = Rect2()
var sprint_touch_index: int = -1

# Screamer system
var screamer_active: bool = false
var screamer_timer: float = 0.0
var screamer_duration: float = 1.5
var screamer_sound: AudioStreamPlayer = null
var random_scare_timer: float = 0.0
var next_scare_time: float = 30.0

# Flashlight battery
var battery: float = 100.0
var battery_drain: float = 3.0
var battery_regen: float = 1.5
var flashlight_on: bool = true

# Camera shake
var camera_shake_intensity: float = 0.0

func _ready():
	win_panel.visible = false
	lose_panel.visible = false
	speed_warning.visible = false
	heartbeat_label.visible = false
	screamer_rect.visible = false
	update_apple_count(0)
	vignette.modulate.a = 0.0
	GameManager.apple_collected.connect(_on_apple_collected)
	GameManager.game_won.connect(_on_game_won)
	GameManager.game_lost.connect(_on_game_lost)
	difficulty_label.text = GameManager.get_difficulty_name()

	if joystick and joystick.has_signal("joystick_input"):
		joystick.joystick_input.connect(_on_joystick_input)

	_setup_screamer_sound()
	next_scare_time = randf_range(25.0, 50.0)

func _setup_screamer_sound():
	screamer_sound = AudioStreamPlayer.new()
	var stream = load("res://audio/screamer.ogg")
	if stream:
		screamer_sound.stream = stream
		screamer_sound.volume_db = 6.0
	add_child(screamer_sound)

func _update_touch_areas():
	var pad = 15.0
	if flashlight_label:
		var r = flashlight_label.get_global_rect()
		flashlight_touch_area = Rect2(r.position.x - pad, r.position.y - pad, r.size.x + pad * 2, r.size.y + pad * 2)
	if sprint_button:
		var r = sprint_button.get_global_rect()
		sprint_touch_area = Rect2(r.position.x - pad, r.position.y - pad, r.size.x + pad * 2, r.size.y + pad * 2)

func _input(event):
	if not GameManager.game_active:
		return

	if event is InputEventScreenTouch:
		_update_touch_areas()
		if event.pressed:
			if flashlight_touch_area.has_point(event.position):
				_toggle_flashlight()
			elif sprint_touch_area.has_point(event.position):
				sprint_touch_index = event.index
				is_sprinting_touch = true
		else:
			if event.index == sprint_touch_index:
				sprint_touch_index = -1
				is_sprinting_touch = false

func _toggle_flashlight():
	var player = get_tree().get_first_node_in_group("player")
	if player and battery > 0:
		var flashlight = player.get_node_or_null("Camera3D/Flashlight")
		if flashlight:
			flashlight_on = !flashlight_on
			flashlight.visible = flashlight_on
			if flashlight_on:
				flashlight_label.text = "[Flashlight ON]"
			else:
				flashlight_label.text = "[Flashlight OFF]"

func _process(delta):
	if warning_timer > 0:
		warning_timer -= delta
		speed_warning.modulate.a = warning_timer / 2.0
		if warning_timer <= 0:
			speed_warning.visible = false

	if shake_amount > 0:
		shake_amount -= delta * 2.0
		vignette.modulate.a = shake_amount * 0.4

	fps_label.visible = GameManager.show_fps
	if GameManager.show_fps:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		stamina_bar.value = player.stamina
		stamina_bar.visible = player.stamina < player.max_stamina
		sprint_label.visible = player.stamina < player.max_stamina
		player.is_sprinting_touch = is_sprinting_touch

	# Flashlight battery system
	if GameManager.game_active and player:
		var flashlight = player.get_node_or_null("Camera3D/Flashlight")
		if flashlight and flashlight.visible:
			battery = max(0, battery - battery_drain * delta)
			if battery <= 0:
				flashlight.visible = false
				flashlight_on = false
				flashlight_label.text = "[NO BATTERY]"
		else:
			battery = min(100.0, battery + battery_regen * delta)
		battery_bar.value = battery
		battery_bar.visible = true
		battery_label.visible = true
		if battery < 20:
			battery_label.text = "BATTERY LOW!"
			battery_label.modulate = Color(1, 0.2, 0.2, 0.6 + sin(heartbeat_time * 4.0) * 0.4)
		else:
			battery_label.text = "Battery"
			battery_label.modulate = Color(1, 1, 1, 0.5)

	# Screamer animation
	if screamer_active:
		screamer_timer += delta
		if screamer_timer < screamer_duration:
			screamer_rect.visible = true
			var shake = sin(screamer_timer * 40.0) * 15.0
			screamer_rect.position = Vector2(shake, sin(screamer_timer * 35.0) * 10.0)
			var flash = abs(sin(screamer_timer * 20.0))
			screamer_rect.modulate = Color(1, flash * 0.3, flash * 0.3, 1.0)
		else:
			screamer_active = false
			screamer_rect.visible = false
			screamer_rect.position = Vector2.ZERO

	# Random mini-scare (screen flicker when Fedos is close)
	if GameManager.game_active:
		random_scare_timer += delta
		if random_scare_timer >= next_scare_time:
			random_scare_timer = 0.0
			next_scare_time = randf_range(25.0, 60.0)
			_trigger_mini_scare()

	# Heartbeat proximity system
	if GameManager.game_active:
		var fedos = _find_fedos()
		if fedos and player:
			var dist = player.global_position.distance_to(fedos.global_position)
			heartbeat_time += delta
			if dist < 30.0:
				heartbeat_label.visible = true
				var intensity = clamp(1.0 - (dist / 30.0), 0.0, 1.0)
				var beat_speed = 2.0 + intensity * 6.0
				var beat = abs(sin(heartbeat_time * beat_speed))
				heartbeat_label.modulate.a = 0.4 + beat * 0.6
				if dist < 10.0:
					heartbeat_label.text = "!! HEARTBEAT RACING !!"
					vignette.modulate.a = max(vignette.modulate.a, intensity * 0.25)
					# Camera shake when very close
					camera_shake_intensity = intensity * 0.3
				elif dist < 20.0:
					heartbeat_label.text = "... thump ... thump ..."
					camera_shake_intensity = intensity * 0.1
				else:
					heartbeat_label.text = "... thump ..."
					camera_shake_intensity = 0.0
			else:
				heartbeat_label.visible = false
				camera_shake_intensity = 0.0

		# Apply camera shake
		if player and camera_shake_intensity > 0:
			var cam = player.get_node_or_null("Camera3D")
			if cam:
				cam.h_offset = sin(heartbeat_time * 15.0) * camera_shake_intensity * 0.02
				cam.v_offset = cos(heartbeat_time * 12.0) * camera_shake_intensity * 0.015

func _trigger_mini_scare():
	vignette.modulate.a = 0.5
	shake_amount = 0.8

func trigger_screamer():
	screamer_active = true
	screamer_timer = 0.0
	if screamer_sound:
		screamer_sound.play()

func _find_fedos() -> Node3D:
	var game = get_tree().current_scene
	if game:
		return game.get_node_or_null("Fedos")
	return null

func update_apple_count(count: int):
	apple_label.text = "Apples: %d / %d" % [count, GameManager.total_apples]

func _on_apple_collected(count: int):
	update_apple_count(count)
	if count % 5 == 0 and count > 0 and count < GameManager.total_apples:
		speed_warning.visible = true
		speed_warning.text = "FEDOS SPEEDS UP!"
		warning_timer = 2.0
		shake_amount = 1.0

func _on_game_won():
	win_panel.visible = true
	joystick.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_game_lost():
	trigger_screamer()
	lose_panel.visible = true
	joystick.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_joystick_input(vec: Vector2):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_joystick_input(vec)
