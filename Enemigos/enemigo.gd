extends CharacterBody2D

@export var target: Node2D
@export var bullet_scene: PackedScene = preload("res://Bala/bala.tscn")
@export var speed := 120
@export var shoot_interval := 2.0

# Rango de distancias
@export var cover_distance := 150
@export var attack_distance := 400

var shoot_timer := 0.0

func _physics_process(delta):
	if not target:
		return

	var distance_to_player = global_position.distance_to(target.global_position)

	# Movimiento táctico
	if distance_to_player < attack_distance:
		# rodear player con offset aleatorio
		var offset = Vector2(randf_range(-50,50), randf_range(-50,50))
		velocity = (target.global_position + offset - global_position).normalized() * speed
	else:
		# acercarse directo
		velocity = (target.global_position - global_position).normalized() * speed

	move_and_slide()

	# Disparo
	shoot_timer -= delta
	if shoot_timer <= 0:
		shoot_timer = shoot_interval + randf_range(-0.5,0.5)  # variación
		shoot()

# ------------------------------
# Funciones auxiliares
# ------------------------------



func can_shoot(player_pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var ray = PhysicsRayQueryParameters2D.new()
	ray.from = global_position
	ray.to = player_pos
	ray.exclude = [self]
	ray.collision_mask = 1  # poner la capa de obstáculos
	var result = space_state.intersect_ray(ray)
	return result.size() == 0  # true sdsi no hay nada bloqueando


func shoot():
	if not bullet_scene:
		return
	var b = bullet_scene.instantiate()
	b.global_position = global_position
	b.direction = (target.global_position - global_position).normalized()
	b.is_player_bullet = false
	get_parent().get_node("../Bullets").add_child(b)
