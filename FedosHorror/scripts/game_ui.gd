extends CanvasLayer

@onready var apple_label: Label = $AppleCounter
@onready var speed_warning: Label = $SpeedWarning
@onready var win_panel: Panel = $WinPanel
@onready var lose_panel: Panel = $LosePanel
@onready var crosshair: TextureRect = $Crosshair
@onready var vignette: ColorRect = $Vignette
@onready var fps_label: Label = $FPSLabel
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var sprint_label: Label = $SprintLabel
@onready var joystick: Control = $VirtualJoystick
@onready var difficulty_label: Label = $DifficultyLabel

var warning_timer: float = 0.0
var shake_amount: float = 0.0

func _ready():
	win_panel.visible = false
	lose_panel.visible = false
	speed_warning.visible = false
	update_apple_count(0)
	vignette.modulate.a = 0.0
	GameManager.apple_collected.connect(_on_apple_collected)
	GameManager.game_won.connect(_on_game_won)
	GameManager.game_lost.connect(_on_game_lost)
	difficulty_label.text = GameManager.get_difficulty_name()

	if joystick and joystick.has_signal("joystick_input"):
		joystick.joystick_input.connect(_on_joystick_input)

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
