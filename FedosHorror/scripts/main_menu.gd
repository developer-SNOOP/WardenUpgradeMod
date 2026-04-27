extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

var time: float = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _process(delta):
	time += delta
	var pulse = 0.8 + sin(time * 2.0) * 0.2
	title_label.modulate = Color(pulse, 0.1, 0.1, 1.0)

func _on_play_pressed():
	GameManager.go_to_game()

func _on_quit_pressed():
	get_tree().quit()
