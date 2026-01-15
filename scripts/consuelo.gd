extends Node2D

@onready var nodo_nivel := $Nivel

var current_level: Node = null

func _ready():
	load_level(preload("res://escenas/niveles/nivel_1.tscn"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func load_level(scene: PackedScene):
	if current_level:
		current_level.queue_free()

	current_level = scene.instantiate()
	nodo_nivel.add_child(current_level)
