extends Node2D

var punteria: Control
var narrative_ui

func _ready():
	
	Estado.day = true
	narrative_ui = get_tree().get_first_node_in_group("narrative_ui")
	punteria = get_tree().get_first_node_in_group("punteria")

	_start_intro()

func _start_intro():
	var file = FileAccess.open(
		"res://datos/narrativa/nivel_1.json",
		FileAccess.READ
	)
	var data = JSON.parse_string(file.get_as_text())

	narrative_ui.show_text(data["intro"])

	await get_tree().create_timer(2.5).timeout

	Estado.day = false


func _on_shot(success: bool):
	if success:
		print("sdf")
	else:
		# jugador muere después
		pass
