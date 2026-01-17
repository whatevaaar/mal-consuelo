extends Node

var current_level: Node = null
var current_ui: Control = null

@onready var nodo_nivel := get_tree().root.get_node("Consuelo/Nivel")
@onready var nodo_ui := get_tree().root.get_node("Consuelo/UI/Pantallas")

func load_level(scene: PackedScene):
	limpiar_pantalla()

	current_level = scene.instantiate()
	nodo_nivel.add_child(current_level)

func load_ui(scene: PackedScene):
	limpiar_pantalla()
	
	current_ui = scene.instantiate()
	nodo_ui.add_child(current_ui)

func limpiar_pantalla():
	if current_ui:
		current_ui.queue_free()
	if current_level:
		current_level.queue_free()
