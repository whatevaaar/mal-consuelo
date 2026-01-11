extends CanvasLayer

@onready var title_label = $Panel/MarginContainer/VBoxContainer/Title
@onready var text_label = $Panel/MarginContainer/VBoxContainer/Text


func show_ending():
	var ending = NarrativeManager.generate_ending(GameState)

	title_label.text = ending.title
	text_label.text = ending.text

	visible = true
