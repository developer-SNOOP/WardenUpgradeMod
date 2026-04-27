extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var difficulty_button: Button = $VBoxContainer/DifficultyButton
@onready var quality_button: Button = $VBoxContainer/QualityButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var settings_panel: Panel = $SettingsPanel
@onready var sensitivity_slider: HSlider = $SettingsPanel/VBox/SensitivityRow/SensitivitySlider
@onready var sensitivity_value: Label = $SettingsPanel/VBox/SensitivityRow/SensitivityValue
@onready var volume_slider: HSlider = $SettingsPanel/VBox/VolumeRow/VolumeSlider
@onready var volume_value: Label = $SettingsPanel/VBox/VolumeRow/VolumeValue
@onready var fps_check: CheckButton = $SettingsPanel/VBox/FPSRow/FPSCheck
@onready var headbob_check: CheckButton = $SettingsPanel/VBox/HeadBobRow/HeadBobCheck
@onready var settings_back: Button = $SettingsPanel/VBox/BackButton
@onready var glow_line1: ColorRect = $GlowLine1
@onready var glow_line2: ColorRect = $GlowLine2
@onready var fedos_image: TextureRect = $FedosImage
@onready var fedos_glow: ColorRect = $FedosGlowOverlay
@onready var scan_line: ColorRect = $ScanLine
@onready var static_noise: ColorRect = $StaticNoise

var time: float = 0.0
var flicker_timer: float = 0.0
var next_flicker: float = 3.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	play_button.pressed.connect(_on_play_pressed)
	difficulty_button.pressed.connect(_on_difficulty_pressed)
	quality_button.pressed.connect(_on_quality_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	settings_back.pressed.connect(_on_settings_back)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	volume_slider.value_changed.connect(_on_volume_changed)
	fps_check.toggled.connect(_on_fps_toggled)
	headbob_check.toggled.connect(_on_headbob_toggled)
	settings_panel.visible = false
	_update_difficulty_label()
	_update_quality_label()
	_load_settings_ui()

func _process(delta):
	time += delta

	# Title pulse
	var pulse = 0.55 + sin(time * 2.0) * 0.45
	title_label.modulate = Color(pulse, 0.06, 0.08, 1.0)

	# Glow lines animate
	if glow_line1:
		glow_line1.modulate.a = 0.3 + sin(time * 1.5) * 0.15
	if glow_line2:
		glow_line2.modulate.a = 0.25 + sin(time * 1.8 + 1.0) * 0.15

	# Scan line moves down
	if scan_line:
		var screen_h = get_viewport().get_visible_rect().size.y
		scan_line.position.y = fmod(time * 80.0, screen_h + 10.0) - 5.0
		scan_line.modulate.a = 0.2 + sin(time * 3.0) * 0.1

	# Fedos image: subtle breathing and occasional flicker
	if fedos_image:
		var breathe = 1.0 + sin(time * 1.5) * 0.02
		fedos_image.scale = Vector2(breathe, breathe)

		flicker_timer += delta
		if flicker_timer > next_flicker:
			flicker_timer = 0.0
			next_flicker = randf_range(2.0, 6.0)
			fedos_image.modulate.a = 0.1
		elif flicker_timer < 0.1 and fedos_image.modulate.a < 0.5:
			fedos_image.modulate.a = 0.6
		else:
			fedos_image.modulate.a = lerp(fedos_image.modulate.a, 0.55, delta * 2.0)

	if fedos_glow:
		fedos_glow.modulate.a = 0.1 + sin(time * 2.5) * 0.08

	# Static noise flicker
	if static_noise:
		static_noise.modulate.a = randf_range(0.01, 0.04)

func _on_play_pressed():
	GameManager.go_to_game()

func _on_difficulty_pressed():
	match GameManager.current_difficulty:
		GameManager.Difficulty.EASY:
			GameManager.set_difficulty(GameManager.Difficulty.MEDIUM)
		GameManager.Difficulty.MEDIUM:
			GameManager.set_difficulty(GameManager.Difficulty.HARD)
		GameManager.Difficulty.HARD:
			GameManager.set_difficulty(GameManager.Difficulty.EASY)
	_update_difficulty_label()
	GameManager.save_settings()

func _on_quality_pressed():
	match GameManager.current_quality:
		GameManager.Quality.LOW:
			GameManager.set_quality(GameManager.Quality.MEDIUM)
		GameManager.Quality.MEDIUM:
			GameManager.set_quality(GameManager.Quality.HIGH)
		GameManager.Quality.HIGH:
			GameManager.set_quality(GameManager.Quality.LOW)
	_update_quality_label()
	GameManager.save_settings()

func _update_difficulty_label():
	var diff_name = GameManager.get_difficulty_name()
	var color_map = {
		"Easy": Color(0.2, 0.85, 0.2),
		"Medium": Color(0.95, 0.75, 0.1),
		"Hard": Color(0.95, 0.12, 0.12),
	}
	difficulty_button.text = "Difficulty: %s" % diff_name
	difficulty_button.add_theme_color_override("font_color", color_map.get(diff_name, Color.WHITE))

func _update_quality_label():
	var q_name = GameManager.get_quality_name()
	var color_map = {
		"Low": Color(0.5, 0.85, 0.5),
		"Medium": Color(0.85, 0.75, 0.3),
		"High": Color(0.95, 0.3, 0.85),
	}
	quality_button.text = "Quality: %s" % q_name
	quality_button.add_theme_color_override("font_color", color_map.get(q_name, Color.WHITE))

func _on_settings_pressed():
	settings_panel.visible = true

func _on_settings_back():
	settings_panel.visible = false
	GameManager.save_settings()

func _on_quit_pressed():
	get_tree().quit()

func _load_settings_ui():
	sensitivity_slider.value = GameManager.look_sensitivity
	sensitivity_value.text = "%.1f" % GameManager.look_sensitivity
	volume_slider.value = GameManager.master_volume
	volume_value.text = "%d%%" % int(GameManager.master_volume * 100)
	fps_check.button_pressed = GameManager.show_fps
	headbob_check.button_pressed = GameManager.head_bob_enabled

func _on_sensitivity_changed(value: float):
	GameManager.look_sensitivity = value
	sensitivity_value.text = "%.1f" % value

func _on_volume_changed(value: float):
	GameManager.master_volume = value
	volume_value.text = "%d%%" % int(value * 100)

func _on_fps_toggled(toggled: bool):
	GameManager.show_fps = toggled

func _on_headbob_toggled(toggled: bool):
	GameManager.head_bob_enabled = toggled
