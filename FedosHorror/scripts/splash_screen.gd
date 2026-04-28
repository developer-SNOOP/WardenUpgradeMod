extends Control

@onready var meox_label: Label = $MeoXLabel
@onready var presents_label: Label = $PresentsLabel
@onready var title_label: Label = $TitleLabel
@onready var bg: ColorRect = $Background

var phase: int = 0
var timer: float = 0.0
var fade_speed: float = 1.5

func _ready():
	meox_label.modulate.a = 0.0
	presents_label.modulate.a = 0.0
	title_label.modulate.a = 0.0
	title_label.visible = false
	phase = 0
	timer = 0.0

func _process(delta):
	timer += delta
	match phase:
		0:
			meox_label.modulate.a = min(meox_label.modulate.a + delta * fade_speed, 1.0)
			if timer > 1.2:
				phase = 1
				timer = 0.0
		1:
			presents_label.modulate.a = min(presents_label.modulate.a + delta * fade_speed, 1.0)
			if timer > 1.5:
				phase = 2
				timer = 0.0
		2:
			meox_label.modulate.a = max(meox_label.modulate.a - delta * fade_speed, 0.0)
			presents_label.modulate.a = max(presents_label.modulate.a - delta * fade_speed, 0.0)
			if timer > 1.2:
				phase = 3
				timer = 0.0
				title_label.visible = true
		3:
			title_label.modulate.a = min(title_label.modulate.a + delta * fade_speed, 1.0)
			if timer > 2.0:
				phase = 4
				timer = 0.0
		4:
			title_label.modulate.a = max(title_label.modulate.a - delta * fade_speed, 0.0)
			if timer > 1.2:
				get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
