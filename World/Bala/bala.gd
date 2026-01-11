extends Area2D

const SPEED := 800.0
const FENCE_GRACE_DISTANCE := 24.0

var direction := Vector2.ZERO
var is_player_bullet := false
var origin := Vector2.ZERO


func _ready():
	origin = global_position
	GameState.shots_fired += 1


func _physics_process(delta):
	position += direction * SPEED * delta


func _on_body_entered(body):
	# -----------------------------
	# FENCE (StaticBody2D)
	# -----------------------------
	if body.is_in_group("fences"):
		var dist := origin.distance_to(global_position)

		# gracia si sale pegado al fence
		if dist < FENCE_GRACE_DISTANCE:
			return

		# chance de bloqueo
		if randf() < body.block_chance:
			queue_free()
		return

	# -----------------------------
	# ANIMALES
	# -----------------------------
	if body.is_in_group("animals"):
		if is_player_bullet and body.has_method("die"):
			body.die()
		queue_free()
		return

	# -----------------------------
	# ENEMIGOS
	# -----------------------------
	if is_player_bullet and body.is_in_group("enemies"):
		GameState.shots_hit += 1
		GameState.enemies_killed += 1
		if body.has_method("die"):
			body.die()
		queue_free()
		return

	# -----------------------------
	# PLAYER
	# -----------------------------
	if not is_player_bullet and body.is_in_group("player"):
		if body.has_method("die"):
			body.die()
		queue_free()
