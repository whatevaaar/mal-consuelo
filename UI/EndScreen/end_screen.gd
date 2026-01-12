extends CanvasLayer

@onready var title_label = $Panel/MarginContainer/VBoxContainer/Title
@onready var text_label = $Panel/MarginContainer/VBoxContainer/Text


func show_ending():
	var ending = NarrativeManager.generate_ending(GameState)

	title_label.text = ending.title
	text_label.text = ending.text

	visible = true

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://game.tscn")


func _on_button_pressed() -> void:
	_on_restart_pressed()
