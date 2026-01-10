extends Area2D

const SPEED := 600.0
var direction := Vector2.ZERO
var is_player_bullet := false

func _physics_process(delta):
	position += direction * SPEED * delta

func _on_body_entered(body):
	if is_player_bullet and body.is_in_group("enemies"):
		body.queue_free()
		queue_free()
	elif not is_player_bullet and body.name == "Player":
		print("Player hit!")
		queue_free()
