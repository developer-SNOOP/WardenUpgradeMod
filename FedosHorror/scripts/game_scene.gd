extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var fedos: CharacterBody3D = $Fedos
@onready var ui: CanvasLayer = $GameUI
@onready var nav_region: NavigationRegion3D = $NavigationRegion3D

var apple_scene: PackedScene

func _ready():
	GameManager.start_game()
	apple_scene = load("res://scenes/apple.tscn")
	_spawn_apples()

func _spawn_apples():
	var apple_positions = _generate_apple_positions()
	for pos in apple_positions:
		var apple = apple_scene.instantiate()
		apple.position = pos
		nav_region.add_child(apple)

func _generate_apple_positions() -> Array[Vector3]:
	var positions: Array[Vector3] = []
	var rooms = [
		# Room 1 - living room area
		{"min": Vector3(-9, 0.5, -9), "max": Vector3(-1, 0.5, -1)},
		# Room 2 - kitchen area
		{"min": Vector3(1, 0.5, -9), "max": Vector3(9, 0.5, -1)},
		# Room 3 - hallway
		{"min": Vector3(-3, 0.5, -1), "max": Vector3(3, 0.5, 1)},
		# Room 4 - bedroom
		{"min": Vector3(-9, 0.5, 1), "max": Vector3(-1, 0.5, 9)},
		# Room 5 - bathroom/storage
		{"min": Vector3(1, 0.5, 1), "max": Vector3(9, 0.5, 9)},
	]

	var rng = RandomNumberGenerator.new()
	rng.seed = hash("fedos_horror_apples")

	for i in range(GameManager.total_apples):
		var room = rooms[i % rooms.size()]
		var pos = Vector3(
			rng.randf_range(room["min"].x + 0.5, room["max"].x - 0.5),
			room["min"].y,
			rng.randf_range(room["min"].z + 0.5, room["max"].z - 0.5)
		)
		positions.append(pos)

	return positions

func _on_menu_pressed():
	GameManager.go_to_menu()

func _on_retry_pressed():
	GameManager.restart()
