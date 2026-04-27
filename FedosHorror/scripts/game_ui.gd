extends CanvasLayer

@onready var apple_label: Label = $AppleCounter
@onready var speed_warning: Label = $SpeedWarning
@onready var win_panel: Panel = $WinPanel
@onready var lose_panel: Panel = $LosePanel
@onready var crosshair: TextureRect = $Crosshair
@onready var vignette: ColorRect = $Vignette

var warning_timer: float = 0.0
var shake_amount: float = 0.0

func _ready():
	win_panel.visible = false
	lose_panel.visible = false
	speed_warning.visible = false
	update_apple_count(0)
	GameManager.apple_collected.connect(_on_apple_collected)
	GameManager.game_won.connect(_on_game_won)
	GameManager.game_lost.connect(_on_game_lost)

func _process(delta):
	if warning_timer > 0:
		warning_timer -= delta
		speed_warning.modulate.a = warning_timer / 2.0
		if warning_timer <= 0:
			speed_warning.visible = false

	if shake_amount > 0:
		shake_amount -= delta * 2.0
		vignette.modulate.a = shake_amount

func update_apple_count(count: int):
	apple_label.text = "Apples: %d / %d" % [count, GameManager.total_apples]

func _on_apple_collected(count: int):
	update_apple_count(count)
	if count % 5 == 0 and count > 0:
		speed_warning.visible = true
		speed_warning.text = "FEDOS SPEEDS UP!"
		warning_timer = 2.0
		shake_amount = 1.0

func _on_game_won():
	win_panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_game_lost():
	lose_panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
