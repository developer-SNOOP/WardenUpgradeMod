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
@onready var particles: CPUParticles2D = $Particles

var time: float = 0.0

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
	var pulse = 0.7 + sin(time * 2.0) * 0.3
	title_label.modulate = Color(pulse, 0.05, 0.05, 1.0)

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
		"Easy": Color(0.2, 0.8, 0.2),
		"Medium": Color(0.9, 0.7, 0.1),
		"Hard": Color(0.9, 0.15, 0.15),
	}
	difficulty_button.text = "Difficulty: %s" % diff_name
	difficulty_button.add_theme_color_override("font_color", color_map.get(diff_name, Color.WHITE))

func _update_quality_label():
	var q_name = GameManager.get_quality_name()
	var color_map = {
		"Low": Color(0.5, 0.8, 0.5),
		"Medium": Color(0.8, 0.7, 0.3),
		"High": Color(0.9, 0.3, 0.8),
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
