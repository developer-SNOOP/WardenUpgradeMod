extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var fedos: CharacterBody3D = $Fedos
@onready var ui: CanvasLayer = $GameUI
@onready var nav_region: NavigationRegion3D = $NavigationRegion3D

var apple_scene: PackedScene
var wall_texture: Texture2D

func _ready():
	apple_scene = load("res://scenes/apple.tscn")
	wall_texture = load("res://textures/wall_inner.png")
	_build_interior_walls()
	_spawn_apples()
	_add_room_lights()

func _build_interior_walls():
	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_texture = wall_texture
	wall_mat.uv1_scale = Vector3(4, 2, 1)
	wall_mat.roughness = 0.9

	var wall_defs = [
		{"pos": Vector3(-20, 1.75, 0), "size": Vector3(30, 3.5, 0.3)},
		{"pos": Vector3(20, 1.75, 0), "size": Vector3(30, 3.5, 0.3)},
		{"pos": Vector3(0, 1.75, -20), "size": Vector3(0.3, 3.5, 30)},
		{"pos": Vector3(0, 1.75, 20), "size": Vector3(0.3, 3.5, 30)},
		{"pos": Vector3(-35, 1.75, -25), "size": Vector3(0.3, 3.5, 18)},
		{"pos": Vector3(-35, 1.75, 25), "size": Vector3(0.3, 3.5, 18)},
		{"pos": Vector3(35, 1.75, -25), "size": Vector3(0.3, 3.5, 18)},
		{"pos": Vector3(35, 1.75, 25), "size": Vector3(0.3, 3.5, 18)},
		{"pos": Vector3(-25, 1.75, -35), "size": Vector3(18, 3.5, 0.3)},
		{"pos": Vector3(25, 1.75, -35), "size": Vector3(18, 3.5, 0.3)},
		{"pos": Vector3(-25, 1.75, 35), "size": Vector3(18, 3.5, 0.3)},
		{"pos": Vector3(25, 1.75, 35), "size": Vector3(18, 3.5, 0.3)},
		{"pos": Vector3(-10, 1.75, -40), "size": Vector3(15, 3.5, 0.3)},
		{"pos": Vector3(10, 1.75, 40), "size": Vector3(15, 3.5, 0.3)},
		{"pos": Vector3(-40, 1.75, 10), "size": Vector3(0.3, 3.5, 15)},
		{"pos": Vector3(40, 1.75, -10), "size": Vector3(0.3, 3.5, 15)},
		{"pos": Vector3(-15, 1.75, -15), "size": Vector3(10, 3.5, 0.3)},
		{"pos": Vector3(15, 1.75, 15), "size": Vector3(10, 3.5, 0.3)},
		{"pos": Vector3(-15, 1.75, 15), "size": Vector3(0.3, 3.5, 10)},
		{"pos": Vector3(15, 1.75, -15), "size": Vector3(0.3, 3.5, 10)},
	]

	for wd in wall_defs:
		var body = StaticBody3D.new()
		body.position = wd["pos"]

		var mesh_inst = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = wd["size"]
		mesh_inst.mesh = box
		mesh_inst.material_override = wall_mat
		body.add_child(mesh_inst)

		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = wd["size"]
		col.shape = shape
		body.add_child(col)

		nav_region.add_child(body)

func _add_room_lights():
	var light_positions = [
		{"pos": Vector3(-30, 2.8, -30), "color": Color(0.6, 0.45, 0.25), "energy": 0.5},
		{"pos": Vector3(30, 2.8, -30), "color": Color(0.3, 0.3, 0.55), "energy": 0.35},
		{"pos": Vector3(-30, 2.8, 30), "color": Color(0.5, 0.2, 0.2), "energy": 0.3},
		{"pos": Vector3(30, 2.8, 30), "color": Color(0.2, 0.4, 0.2), "energy": 0.25},
		{"pos": Vector3(0, 2.8, 0), "color": Color(0.7, 0.5, 0.3), "energy": 0.4},
		{"pos": Vector3(-45, 2.8, 0), "color": Color(0.4, 0.3, 0.5), "energy": 0.3},
		{"pos": Vector3(45, 2.8, 0), "color": Color(0.5, 0.4, 0.2), "energy": 0.25},
		{"pos": Vector3(0, 2.8, -45), "color": Color(0.3, 0.5, 0.3), "energy": 0.2},
		{"pos": Vector3(0, 2.8, 45), "color": Color(0.5, 0.2, 0.3), "energy": 0.3},
	]
	for ld in light_positions:
		var light = OmniLight3D.new()
		light.position = ld["pos"]
		light.light_color = ld["color"]
		light.light_energy = ld["energy"]
		light.omni_range = 10.0
		light.omni_attenuation = 1.5
		light.shadow_enabled = false
		add_child(light)

func _spawn_apples():
	var apple_positions = _generate_apple_positions()
	for pos in apple_positions:
		var apple = apple_scene.instantiate()
		apple.position = pos
		nav_region.add_child(apple)

func _generate_apple_positions() -> Array[Vector3]:
	var positions: Array[Vector3] = []
	var zones = [
		{"min": Vector3(-50, 0.5, -50), "max": Vector3(-25, 0.5, -25)},
		{"min": Vector3(-25, 0.5, -50), "max": Vector3(0, 0.5, -25)},
		{"min": Vector3(0, 0.5, -50), "max": Vector3(25, 0.5, -25)},
		{"min": Vector3(25, 0.5, -50), "max": Vector3(50, 0.5, -25)},
		{"min": Vector3(-50, 0.5, -25), "max": Vector3(-25, 0.5, 0)},
		{"min": Vector3(-25, 0.5, -25), "max": Vector3(0, 0.5, 0)},
		{"min": Vector3(0, 0.5, -25), "max": Vector3(25, 0.5, 0)},
		{"min": Vector3(25, 0.5, -25), "max": Vector3(50, 0.5, 0)},
		{"min": Vector3(-50, 0.5, 0), "max": Vector3(-25, 0.5, 25)},
		{"min": Vector3(-25, 0.5, 0), "max": Vector3(0, 0.5, 25)},
		{"min": Vector3(0, 0.5, 0), "max": Vector3(25, 0.5, 25)},
		{"min": Vector3(25, 0.5, 0), "max": Vector3(50, 0.5, 25)},
		{"min": Vector3(-50, 0.5, 25), "max": Vector3(-25, 0.5, 50)},
		{"min": Vector3(-25, 0.5, 25), "max": Vector3(0, 0.5, 50)},
		{"min": Vector3(0, 0.5, 25), "max": Vector3(25, 0.5, 50)},
		{"min": Vector3(25, 0.5, 25), "max": Vector3(50, 0.5, 50)},
	]

	var rng = RandomNumberGenerator.new()
	rng.seed = hash("fedos_horror_big_map")

	for i in range(GameManager.total_apples):
		var zone = zones[i % zones.size()]
		var pos = Vector3(
			rng.randf_range(zone["min"].x + 2.0, zone["max"].x - 2.0),
			zone["min"].y,
			rng.randf_range(zone["min"].z + 2.0, zone["max"].z - 2.0)
		)
		positions.append(pos)

	return positions

func _on_menu_pressed():
	GameManager.go_to_menu()

func _on_retry_pressed():
	GameManager.restart()


