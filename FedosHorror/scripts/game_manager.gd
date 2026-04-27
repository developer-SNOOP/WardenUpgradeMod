extends Node

var apples_collected: int = 0
var total_apples: int = 30
var game_active: bool = false
var fedos_base_speed: float = 2.0
var fedos_speed_increment: float = 0.8

signal apple_collected(count: int)
signal game_won()
signal game_lost()

func _ready():
	pass

func start_game():
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
	var speed_multiplier = int(apples_collected / 5)
	return fedos_base_speed + (speed_multiplier * fedos_speed_increment)

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
