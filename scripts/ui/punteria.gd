extends Control

@export var speed := 6.0
@export var tick := 0.016

@onready var barra_centro := $Barra/MarginContainer/BarraCentro
@onready var mira := barra_centro.get_node("sprite_mira")
@onready var zona := barra_centro.get_node("zona_acierto")

var dir := 1
var activo := true
var min_y := 0.0
var max_y := 0.0

signal resolved(success: bool)

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mira.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mira.position = Vector2(mira.position.x, 0)

	await resized
	_calculate_limits()
	_start_timer()

func _calculate_limits():
	var barra_h = barra_centro.size.y
	var mira_h = mira.size.y

	min_y = 0.0
	max_y = barra_h - mira_h

	mira.position.y = clampf(mira.position.y, min_y, max_y)

func _start_timer():
	var t := Timer.new()
	t.wait_time = tick
	t.autostart = true
	add_child(t)
	t.timeout.connect(_on_tick)

func _on_tick():
	if not activo:
		return

	mira.position.y += speed * dir
	mira.position.y = clampf(mira.position.y, min_y, max_y)

	if mira.position.y <= min_y or mira.position.y >= max_y:
		dir *= -1

func _unhandled_input(event):
	if activo and event.is_action_pressed("ui_accept"):
		_check_hit()

func _check_hit():
	var mira_rect := Rect2(mira.global_position, mira.size)
	var zona_rect := Rect2(zona.global_position, zona.size)

	_resolve(mira_rect.intersects(zona_rect))

func _resolve(success: bool):
	activo = false
	emit_signal("resolved", success)
