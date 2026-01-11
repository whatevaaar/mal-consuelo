extends CharacterBody2D

@export var target: Node2D
@export var bullet_scene: PackedScene = preload("res://World/Bala/bala.tscn")
@onready var onscreen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


@export var speed := 120
@export var shoot_interval := 2.0

# Distancias
@export var vision_distance := 150  
@export var cover_distance := 150

var shoot_timer := 0.0


func _physics_process(delta):
	if not target:
		return

	var distance_to_player = global_position.distance_to(target.global_position)

	var sees_player := can_see_player()
	var on_screen := onscreen.is_on_screen()


	if sees_player and on_screen:
		if player_has_cover():
			# jugador cubierto → moverme tácticamente
			var offset = Vector2(
				randf_range(-60, 60),
				randf_range(-60, 60)
			)
			velocity = (target.global_position + offset - global_position).normalized() * speed
		else:
			# jugador expuesto → detenerse y disparar
			velocity = Vector2.ZERO
			_handle_shooting(delta)
	else:
		# no lo ve o no está en cámara → avanzar
		velocity = (target.global_position - global_position).normalized() * speed

	move_and_slide()


# --------------------------------
# VISIÓN / CÁMARA
# --------------------------------
func can_see_player() -> bool:
	var dir = target.global_position - global_position
	if dir.length() > vision_distance:
		return false

	var space_state = get_world_2d().direct_space_state
	var ray := PhysicsRayQueryParameters2D.new()

	ray.from = global_position
	ray.to = global_position + dir.normalized() * vision_distance
	ray.exclude = [self]
	ray.collision_mask = 1

	var result = space_state.intersect_ray(ray)

	# si no golpea nada → no lo ve
	if result.is_empty():
		return false

	# si el primer hit es el player → lo ve
	return result.collider == target


func player_has_cover() -> bool:
	var dir = target.global_position - global_position
	if dir.length() > vision_distance:
		return false

	var space_state = get_world_2d().direct_space_state
	var ray := PhysicsRayQueryParameters2D.new()

	ray.from = global_position
	ray.to = global_position + dir.normalized() * vision_distance
	ray.exclude = [self]
	ray.collision_mask = 4  # fences

	var result = space_state.intersect_ray(ray)

	if result.is_empty():
		return false

	if not result.collider.is_in_group("fences"):
		return false

	var fence_pos = result.position
	var enemy_dist = global_position.distance_to(fence_pos)
	var player_dist = target.global_position.distance_to(fence_pos)

	# ❌ si el player está MÁS cerca del fence → no es cover usable
	if player_dist <= enemy_dist:
		return false

	return true


# --------------------------------
# DISPARO
# --------------------------------
func _handle_shooting(delta):
	shoot_timer -= delta
	if shoot_timer <= 0.0:
		shoot_timer = shoot_interval + randf_range(-0.5, 0.5)
		shoot()


func shoot():
	if not bullet_scene:
		return

	var b = bullet_scene.instantiate()
	b.global_position = global_position
	b.direction = (target.global_position - global_position).normalized()
	b.is_player_bullet = false

	get_parent().get_node("../Bullets").add_child(b)


# --------------------------------
# VIDA / MUERTE
# --------------------------------
func die():
	queue_free()
