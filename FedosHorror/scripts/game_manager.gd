extends Node

enum Difficulty { EASY, MEDIUM, HARD }

var apples_collected: int = 0
var total_apples: int = 30
var game_active: bool = false
var current_difficulty: Difficulty = Difficulty.MEDIUM

var difficulty_settings = {
	Difficulty.EASY: {
		"fedos_base_speed": 1.5,
		"fedos_speed_increment": 0.5,
		"total_apples": 20,
		"flashlight_range": 20.0,
		"fedos_detection_delay": 3.0,
		"player_speed": 5.0,
		"sprint_speed": 7.5,
	},
	Difficulty.MEDIUM: {
		"fedos_base_speed": 2.5,
		"fedos_speed_increment": 0.8,
		"total_apples": 30,
		"flashlight_range": 15.0,
		"fedos_detection_delay": 1.0,
		"player_speed": 4.5,
		"sprint_speed": 6.5,
	},
	Difficulty.HARD: {
		"fedos_base_speed": 3.5,
		"fedos_speed_increment": 1.2,
		"total_apples": 40,
		"flashlight_range": 10.0,
		"fedos_detection_delay": 0.0,
		"player_speed": 4.0,
		"sprint_speed": 5.5,
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
	get_tree().reload_current_scene()

func go_to_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func go_to_game():
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

func _save_settings():
	var config = ConfigFile.new()
	config.set_value("settings", "look_sensitivity", look_sensitivity)
	config.set_value("settings", "master_volume", master_volume)
	config.set_value("settings", "sfx_volume", sfx_volume)
	config.set_value("settings", "show_fps", show_fps)
	config.set_value("settings", "head_bob_enabled", head_bob_enabled)
	config.set_value("settings", "difficulty", current_difficulty)
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

func save_settings():
	_save_settings()
