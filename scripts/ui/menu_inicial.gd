extends Control

func _on_button_pressed() -> void:
	LevelManager.load_level(preload("res://escenas/niveles/nivel_1.tscn"))
