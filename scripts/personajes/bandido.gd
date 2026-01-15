extends CharacterBody2D
class_name Bandido

## Estado básico
@export var vida := 1
var vivo := true

@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# El bandido no hace nada al iniciar.
	# Su presencia ya es amenaza suficiente.
	pass


func recibir_disparo() -> void:
	if not vivo:
		return

	vivo = false
	vida -= 1

	# Feedback mínimo, seco
	_on_morir()


func _on_morir() -> void:
	# Nada heroico.
	# Sin animación por ahora.
	queue_free()
