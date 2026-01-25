extends Control

@onready var cuerpo = $VBoxContainer/Cuerpo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cuerpo.text = Historia.generar_parrafo_final()
	pass

func _on_button_pressed() -> void:
	LevelManager.load_level(preload("res://escenas/niveles/nivel_1.tscn"))
