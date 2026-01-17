extends CharacterBody2D

@export var speed := 600.0
var tirador: Node = null

func _ready():
	if tirador:
		add_collision_exception_with(tirador)

func _physics_process(delta):
	var collision := move_and_collide(velocity * delta)
	if collision:
		_on_hit(collision.get_collider())

func _on_hit(body: Node):
	if body == tirador:
		return

	if body.is_in_group("enemigos"):
		body.morir()
		queue_free()
		return

	if body.is_in_group("jugador") and tirador != body:
		body.morir()
		queue_free()
		return

	queue_free()

func _damage(body):
	if body.has_method("damage"):
		body.damage(1)
