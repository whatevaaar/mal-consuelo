extends Node

var current_level: Node = null
var current_ui: Control = null

@onready var nodo_nivel := get_tree().root.get_node("Consuelo/Nivel")
@onready var nodo_ui := get_tree().root.get_node("Consuelo/UI/Pantallas")

func load_level(scene: PackedScene):
	_limpiar_pantalla()

	current_level = scene.instantiate()
	nodo_nivel.add_child(current_level)
	
	await get_tree().process_frame
	_conectar_jugador()
	

func load_ui(scene: PackedScene):
	_limpiar_pantalla()
	
	current_ui = scene.instantiate()
	nodo_ui.add_child(current_ui)

func _limpiar_pantalla():
	if current_ui:
		current_ui.queue_free()
	if current_level:
		current_level.queue_free()
		
		
func _conectar_jugador():
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.connect("muerte", Callable(self, "_on_jugador_muere"))

func _mostrar_pantalla_final():
	load_ui(preload("res://escenas/ui/pantalla_final.tscn"))



func _on_jugador_muere():
	_limpiar_pantalla()
	_mostrar_pantalla_final()
	
