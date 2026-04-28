extends Control

@onready var base_circle: ColorRect = $Base
@onready var knob: ColorRect = $Base/Knob

var is_pressed: bool = false
var touch_index: int = -1
var joystick_output: Vector2 = Vector2.ZERO
var max_distance: float = 60.0

signal joystick_input(vec: Vector2)

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_in_joystick_area(event.position) and touch_index == -1:
				is_pressed = true
				touch_index = event.index
				_update_knob(event.position)
		else:
			if event.index == touch_index:
				_reset()

	if event is InputEventScreenDrag:
		if event.index == touch_index and is_pressed:
			_update_knob(event.position)

func _is_in_joystick_area(pos: Vector2) -> bool:
	var rect = base_circle.get_global_rect()
	var expanded = Rect2(rect.position - Vector2(40, 40), rect.size + Vector2(80, 80))
	return expanded.has_point(pos)

func _update_knob(touch_pos: Vector2):
	var center = base_circle.global_position + base_circle.size / 2.0
	var diff = touch_pos - center
	var dist = diff.length()
	if dist > max_distance:
		diff = diff.normalized() * max_distance

	knob.position = (base_circle.size / 2.0) + diff - (knob.size / 2.0)
	joystick_output = diff / max_distance
	joystick_input.emit(joystick_output)

func _reset():
	is_pressed = false
	touch_index = -1
	joystick_output = Vector2.ZERO
	knob.position = (base_circle.size / 2.0) - (knob.size / 2.0)
	joystick_input.emit(Vector2.ZERO)
