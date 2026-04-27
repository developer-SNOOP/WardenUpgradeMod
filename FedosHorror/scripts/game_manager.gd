extends Node

enum Difficulty { EASY, MEDIUM, HARD }
enum Quality { LOW, MEDIUM, HIGH }

var apples_collected: int = 0
var total_apples: int = 30
var game_active: bool = false
var current_difficulty: Difficulty = Difficulty.MEDIUM
var current_quality: Quality = Quality.MEDIUM

var difficulty_settings = {
	Difficulty.EASY: {
		"fedos_base_speed": 2.0,
		"fedos_speed_increment": 0.6,
		"total_apples": 20,
		"flashlight_range": 25.0,
		"fedos_detection_delay": 5.0,
		"player_speed": 5.5,
		"sprint_speed": 8.0,
	},
	Difficulty.MEDIUM: {
		"fedos_base_speed": 3.0,
		"fedos_speed_increment": 0.9,
		"total_apples": 30,
		"flashlight_range": 18.0,
		"fedos_detection_delay": 2.0,
		"player_speed": 5.0,
		"sprint_speed": 7.0,
	},
	Difficulty.HARD: {
		"fedos_base_speed": 4.0,
		"fedos_speed_increment": 1.4,
		"total_apples": 40,
		"flashlight_range": 12.0,
		"fedos_detection_delay": 0.0,
		"player_speed": 4.5,
		"sprint_speed": 6.0,
	}
}

# Settings
var look_sensitivity: float = 1.0
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var show_fps: bool = false
var head_bob_enabled: bool = true

signal apple_collected(count: int)
signal game_won()
signal game_lost()

func _ready():
	_load_settings()
	_apply_quality()

func start_game():
	var settings = difficulty_settings[current_difficulty]
	total_apples = settings["total_apples"]
	apples_collected = 0
	game_active = true

func collect_apple():
	if not game_active:
		return
	apples_collected += 1
	apple_collected.emit(apples_collected)
	if apples_collected >= total_apples:
		game_active = false
		game_won.emit()

func get_fedos_speed() -> float:
	var settings = difficulty_settings[current_difficulty]
	var speed_multiplier = int(apples_collected / 5)
	return settings["fedos_base_speed"] + (speed_multiplier * settings["fedos_speed_increment"])

func get_player_speed() -> float:
	return difficulty_settings[current_difficulty]["player_speed"]

func get_sprint_speed() -> float:
	return difficulty_settings[current_difficulty]["sprint_speed"]

func get_flashlight_range() -> float:
	return difficulty_settings[current_difficulty]["flashlight_range"]

func get_detection_delay() -> float:
	return difficulty_settings[current_difficulty]["fedos_detection_delay"]

func lose_game():
	if not game_active:
		return
	game_active = false
	game_lost.emit()

func restart():
	start_game()
	get_tree().reload_current_scene()

func go_to_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func go_to_game():
	start_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func set_difficulty(diff: Difficulty):
	current_difficulty = diff

func get_difficulty_name() -> String:
	match current_difficulty:
		Difficulty.EASY:
			return "Easy"
		Difficulty.MEDIUM:
			return "Medium"
		Difficulty.HARD:
			return "Hard"
	return "Medium"

func set_quality(q: Quality):
	current_quality = q
	_apply_quality()

func get_quality_name() -> String:
	match current_quality:
		Quality.LOW:
			return "Low"
		Quality.MEDIUM:
			return "Medium"
		Quality.HIGH:
			return "High"
	return "Medium"

func _apply_quality():
	var vp = get_viewport()
	if vp == null:
		return
	match current_quality:
		Quality.LOW:
			vp.scaling_3d_scale = 0.5
			vp.msaa_3d = Viewport.MSAA_DISABLED
			RenderingServer.directional_shadow_atlas_set_size(512, false)
		Quality.MEDIUM:
			vp.scaling_3d_scale = 0.75
			vp.msaa_3d = Viewport.MSAA_DISABLED
			RenderingServer.directional_shadow_atlas_set_size(1024, false)
		Quality.HIGH:
			vp.scaling_3d_scale = 1.0
			vp.msaa_3d = Viewport.MSAA_2X
			RenderingServer.directional_shadow_atlas_set_size(2048, true)

func _save_settings():
	var config = ConfigFile.new()
	config.set_value("settings", "look_sensitivity", look_sensitivity)
	config.set_value("settings", "master_volume", master_volume)
	config.set_value("settings", "sfx_volume", sfx_volume)
	config.set_value("settings", "show_fps", show_fps)
	config.set_value("settings", "head_bob_enabled", head_bob_enabled)
	config.set_value("settings", "difficulty", current_difficulty)
	config.set_value("settings", "quality", current_quality)
	config.save("user://settings.cfg")

func _load_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		look_sensitivity = config.get_value("settings", "look_sensitivity", 1.0)
		master_volume = config.get_value("settings", "master_volume", 1.0)
		sfx_volume = config.get_value("settings", "sfx_volume", 1.0)
		show_fps = config.get_value("settings", "show_fps", false)
		head_bob_enabled = config.get_value("settings", "head_bob_enabled", true)
		current_difficulty = config.get_value("settings", "difficulty", Difficulty.MEDIUM)
		current_quality = config.get_value("settings", "quality", Quality.MEDIUM)

func save_settings():
	_save_settings()
