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
	_build_toilet_cabin()
	_build_lockers()
	_add_ambient_sounds()

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

func _build_toilet_cabin():
	var toilet_pos = Vector3(-45, 0, -45)

	# Cabin walls (3 sides)
	var cabin_mat = StandardMaterial3D.new()
	cabin_mat.albedo_color = Color(0.15, 0.15, 0.18)
	cabin_mat.roughness = 0.85

	var cabin_walls = [
		{"pos": Vector3(0, 1.5, -0.9), "size": Vector3(2.0, 3.0, 0.1)},
		{"pos": Vector3(0, 1.5, 0.9), "size": Vector3(2.0, 3.0, 0.1)},
		{"pos": Vector3(-1.0, 1.5, 0), "size": Vector3(0.1, 3.0, 1.9)},
	]

	for cw in cabin_walls:
		var body = StaticBody3D.new()
		body.position = toilet_pos + cw["pos"]
		var mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = cw["size"]
		mesh.mesh = box
		mesh.material_override = cabin_mat
		body.add_child(mesh)
		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = cw["size"]
		col.shape = shape
		body.add_child(col)
		add_child(body)

	# Toilet door (opens when Fedos spawns)
	var door = MeshInstance3D.new()
	door.name = "ToiletDoor"
	var door_mesh = BoxMesh.new()
	door_mesh.size = Vector3(0.1, 3.0, 1.8)
	door.mesh = door_mesh
	var door_mat = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.25, 0.12, 0.08)
	door_mat.roughness = 0.9
	door.material_override = door_mat
	door.position = toilet_pos + Vector3(1.0, 1.5, 0)
	add_child(door)

	# Give door reference to Fedos
	if fedos:
		fedos.toilet_door = door

	# Toilet light (dim, flickering)
	var toilet_light = OmniLight3D.new()
	toilet_light.position = toilet_pos + Vector3(0, 2.5, 0)
	toilet_light.light_color = Color(0.8, 0.3, 0.1)
	toilet_light.light_energy = 0.4
	toilet_light.omni_range = 5.0
	toilet_light.shadow_enabled = false
	add_child(toilet_light)

func _build_lockers():
	var locker_mat = StandardMaterial3D.new()
	locker_mat.albedo_color = Color(0.2, 0.22, 0.25)
	locker_mat.metallic = 0.6
	locker_mat.roughness = 0.5

	var locker_positions = [
		Vector3(-30, 0, -10),
		Vector3(30, 0, 10),
		Vector3(-10, 0, 30),
		Vector3(10, 0, -30),
		Vector3(-40, 0, 40),
		Vector3(40, 0, -40),
		Vector3(0, 0, -42),
		Vector3(0, 0, 42),
	]

	for lp in locker_positions:
		var locker = StaticBody3D.new()
		locker.position = lp
		locker.add_to_group("locker")

		# Locker body
		var mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(0.8, 2.2, 0.6)
		mesh.mesh = box
		mesh.position.y = 1.1
		mesh.material_override = locker_mat
		locker.add_child(mesh)

		# Collision
		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = Vector3(0.8, 2.2, 0.6)
		col.shape = shape
		col.position.y = 1.1
		locker.add_child(col)

		# Door detail (thin plane)
		var door_detail = MeshInstance3D.new()
		var door_box = BoxMesh.new()
		door_box.size = Vector3(0.75, 2.0, 0.02)
		door_detail.mesh = door_box
		door_detail.position = Vector3(0, 1.1, -0.32)
		var door_mat = StandardMaterial3D.new()
		door_mat.albedo_color = Color(0.18, 0.2, 0.23)
		door_mat.metallic = 0.5
		door_detail.material_override = door_mat
		locker.add_child(door_detail)

		# Small vent slots on door
		var vent = MeshInstance3D.new()
		var vent_box = BoxMesh.new()
		vent_box.size = Vector3(0.4, 0.02, 0.04)
		vent.mesh = vent_box
		var vent_mat = StandardMaterial3D.new()
		vent_mat.albedo_color = Color(0.05, 0.05, 0.05)
		vent.material_override = vent_mat
		vent.position = Vector3(0, 1.5, -0.34)
		locker.add_child(vent)

		add_child(locker)

func _add_ambient_sounds():
	# Ambient drip sound (creates atmosphere)
	var ambient = AudioStreamPlayer.new()
	ambient.name = "AmbientSound"
	# We'll use voice line as placeholder ambient
	add_child(ambient)

func _add_room_lights():
	var light_positions = [
		{"pos": Vector3(-30, 2.8, -30), "color": Color(0.7, 0.5, 0.3), "energy": 0.6, "range": 14.0},
		{"pos": Vector3(30, 2.8, -30), "color": Color(0.35, 0.35, 0.6), "energy": 0.4, "range": 12.0},
		{"pos": Vector3(-30, 2.8, 30), "color": Color(0.6, 0.25, 0.2), "energy": 0.35, "range": 11.0},
		{"pos": Vector3(30, 2.8, 30), "color": Color(0.25, 0.5, 0.25), "energy": 0.3, "range": 10.0},
		{"pos": Vector3(0, 2.8, 0), "color": Color(0.8, 0.6, 0.35), "energy": 0.5, "range": 16.0},
		{"pos": Vector3(-45, 2.8, 0), "color": Color(0.5, 0.35, 0.55), "energy": 0.35, "range": 12.0},
		{"pos": Vector3(45, 2.8, 0), "color": Color(0.6, 0.45, 0.25), "energy": 0.3, "range": 11.0},
		{"pos": Vector3(0, 2.8, -45), "color": Color(0.35, 0.55, 0.35), "energy": 0.25, "range": 10.0},
		{"pos": Vector3(0, 2.8, 45), "color": Color(0.6, 0.25, 0.35), "energy": 0.35, "range": 12.0},
		{"pos": Vector3(-15, 2.8, -15), "color": Color(0.8, 0.4, 0.2), "energy": 0.2, "range": 8.0},
		{"pos": Vector3(15, 2.8, 15), "color": Color(0.3, 0.3, 0.7), "energy": 0.2, "range": 8.0},
		{"pos": Vector3(-40, 2.8, -40), "color": Color(0.5, 0.2, 0.15), "energy": 0.15, "range": 7.0},
		{"pos": Vector3(40, 2.8, 40), "color": Color(0.15, 0.4, 0.2), "energy": 0.15, "range": 7.0},
	]
	for ld in light_positions:
		var light = OmniLight3D.new()
		light.position = ld["pos"]
		light.light_color = ld["color"]
		light.light_energy = ld["energy"]
		light.omni_range = ld["range"]
		light.omni_attenuation = 1.2
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

func _on_retry_pressed():
	GameManager.restart()

func _on_menu_pressed():
	GameManager.go_to_menu()
