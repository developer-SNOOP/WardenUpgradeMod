extends Area3D

var rotation_speed: float = 2.0
var bob_speed: float = 2.0
var bob_height: float = 0.15
var start_y: float = 0.0
var time: float = 0.0
var collected: bool = false

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var glow: OmniLight3D = $GlowLight

func _ready():
	start_y = global_position.y
	time = randf() * TAU
	body_entered.connect(_on_body_entered)

func _process(delta):
	if collected:
		return
	time += delta
	rotation.y += rotation_speed * delta
	global_position.y = start_y + sin(time * bob_speed) * bob_height

	if glow:
		glow.light_energy = 0.5 + sin(time * 3.0) * 0.2

func _on_body_entered(body):
	if collected:
		return
	if body.is_in_group("player"):
		collected = true
		GameManager.collect_apple()
		queue_free()
