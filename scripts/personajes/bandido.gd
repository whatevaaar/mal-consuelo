extends CharacterBody2D

var alive := true
signal clicked(enemy)

@onready var area := $Area2D  # tu Area2D dentro del body

func _ready():
	add_to_group("enemigos")
	# conectar la señal input_event del Area2D
	area.connect("input_event", Callable(self, "_on_area_input"))

func _on_area_input(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked", self)

func die():
	alive = false
	queue_free()
