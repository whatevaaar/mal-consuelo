extends CanvasLayer

@export var lines: = []
@export var char_speed := 0.05   # segundos por letra
@export var line_duration := 2.0 # cuánto dura la línea completa
@export var exit_duration := 0.15

var current_line := 0
var showing_text := ""
var finished_line := false
var label: Label
var panel: Control


var char_timer := 0.0
var line_timer: Timer


func _ready():
	label = $Panel/CenterContainer/Label
	panel = $Panel

	# Timer para desaparecer
	line_timer = Timer.new()
	line_timer.wait_time = line_duration
	line_timer.one_shot = true
	line_timer.timeout.connect(_on_timer_timeout)
	add_child(line_timer)

	# Animación de entrada
	panel.scale = Vector2(0.9, 0.9)
	panel.modulate.a = 0.0

	create_tween()\
		.tween_property(panel, "scale", Vector2.ONE, 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	create_tween().tween_property(panel, "modulate:a", 1.0, 0.15)


	show_line(current_line)


func _process(delta):
	if current_line >= lines.size():
		queue_free()
		return

	# Ya terminó la línea → esperar timer
	if finished_line:
		return

	# Escritura letra por letra
	char_timer += delta
	if char_timer >= char_speed:
		char_timer -= char_speed

		if showing_text.length() < lines[current_line].length():
			showing_text += lines[current_line][showing_text.length()]
			label.text = showing_text
		else:
			finished_line = true
			line_timer.start()


func show_line(_index):
	showing_text = ""
	label.text = ""
	finished_line = false
	char_timer = 0.0


func _on_timer_timeout():
	var t = create_tween()

	t.tween_property(panel, "scale", Vector2(0.9, 0.9), exit_duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN)

	t.parallel()\
		.tween_property(panel, "modulate:a", 0.0, exit_duration)

	t.finished.connect(queue_free)
