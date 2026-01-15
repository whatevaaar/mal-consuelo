extends Control

@onready var label: RichTextLabel = $MarginContainer/RichTextLabel

var text_queue: Array = []
var typing_speed := 0.03
var _typing := false

func show_text(lines: Array):
	text_queue = lines
	_next_line()

func _next_line():
	if text_queue.is_empty():
		return
	label.text = ""
	_typing = true
	var line = text_queue.pop_front()
	for c in line:
		label.text += c
		await get_tree().create_timer(typing_speed).timeout
	_typing = false
