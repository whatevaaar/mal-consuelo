extends CharacterBody2D

@export var target: Node2D
@export var bullet_scene: PackedScene = preload("res://World/Bala/bala.tscn")
@export var speed := 120
@export var shoot_interval := 2.0

# Distancias
@export var cover_distance := 150
@export var attack_distance := 400

var shoot_timer := 0.0


func _physics_process(delta):
	if not target:
		return

	var distance_to_player = global_position.distance_to(target.global_position)

	var sees_player := can_see_player()

	if sees_player:
		if player_has_cover():
			# jugador cubierto → moverme tácticamente
			var offset = Vector2(randf_range(-60, 60), randf_range(-60, 60))
			velocity = (target.global_position + offset - global_position).normalized() * speed
		else:
			# jugador expuesto → parar y disparar
			velocity = Vector2.ZERO
			_handle_shooting(delta)
	else:
		# no ve al jugador → avanzar (por ahora hacia él / hogar)
		velocity = (target.global_position - global_position).normalized() * speed

	move_and_slide()


# --------------------------------
# VISIÓN / COVER
# --------------------------------
func can_see_player() -> bool:
	var space_state = get_world_2d().direct_space_state
	var ray = PhysicsRayQueryParameters2D.new()
	ray.from = global_position
	ray.to = target.global_position
	ray.exclude = [self]
	ray.collision_mask = 1  # obstáculos / fences

	var result = space_state.intersect_ray(ray)
	return not result.is_empty()


func player_has_cover() -> bool:
	var space_state = get_world_2d().direct_space_state
	var ray = PhysicsRayQueryParameters2D.new()
	ray.from = global_position
	ray.to = target.global_position
	ray.exclude = [self]
	ray.collision_mask = 4 

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
