extends Node2D

@onready var nodo_nivel := $Nivel

var current_level: Node = null

func _ready():
	LevelManager.load_ui(preload("res://escenas/ui/menu_inicial.tscn"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
