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

var warning_timer: float = 0.0
var shake_amount: float = 0.0
var heartbeat_time: float = 0.0
var is_sprinting_touch: bool = false
var flashlight_touch_area: Rect2 = Rect2()
var sprint_touch_area: Rect2 = Rect2()
var sprint_touch_index: int = -1

func _ready():
	win_panel.visible = false
	lose_panel.visible = false
	speed_warning.visible = false
	heartbeat_label.visible = false
	update_apple_count(0)
	vignette.modulate.a = 0.0
	GameManager.apple_collected.connect(_on_apple_collected)
	GameManager.game_won.connect(_on_game_won)
	GameManager.game_lost.connect(_on_game_lost)
	difficulty_label.text = GameManager.get_difficulty_name()

	if joystick and joystick.has_signal("joystick_input"):
		joystick.joystick_input.connect(_on_joystick_input)

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
	if player:
		var flashlight = player.get_node_or_null("Camera3D/Flashlight")
		if flashlight:
			flashlight.visible = !flashlight.visible
			if flashlight.visible:
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

	# Heartbeat proximity system
	if GameManager.game_active:
		var fedos = get_tree().get_first_node_in_group("fedos") if false else _find_fedos()
		if fedos and player:
			var dist = player.global_position.distance_to(fedos.global_position)
			heartbeat_time += delta
			if dist < 30.0:
				heartbeat_label.visible = true
				var intensity = clamp(1.0 - (dist / 30.0), 0.0, 1.0)
				var beat_speed = 2.0 + intensity * 6.0
				var beat = abs(sin(heartbeat_time * beat_speed))
				heartbeat_label.modulate.a = 0.4 + beat * 0.6
				if dist < 15.0:
					heartbeat_label.text = "!! HEARTBEAT RACING !!"
					vignette.modulate.a = max(vignette.modulate.a, intensity * 0.15)
				elif dist < 25.0:
					heartbeat_label.text = "... thump ... thump ..."
				else:
					heartbeat_label.text = "... thump ..."
			else:
				heartbeat_label.visible = false

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
	lose_panel.visible = true
	joystick.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_joystick_input(vec: Vector2):
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_joystick_input"):
		player.set_joystick_input(vec)
