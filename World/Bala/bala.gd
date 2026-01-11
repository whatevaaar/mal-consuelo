extends Area2D

const SPEED := 800.0
var direction := Vector2.ZERO
var is_player_bullet := false
const FENCE_GRACE_DISTANCE := 24.0  # px desde el origen

var origin := Vector2.ZERO

func _physics_process(delta):
	position += direction * SPEED * delta

func _ready():
	GameState.shots_fired += 1
	origin = global_position
	connect("area_entered", Callable(self, "_on_area_entered"))
	
func _on_body_entered(body):
	if  body.is_in_group("animals"):
		if is_player_bullet and body.has_method("die"):
			body.die()
		queue_free()
		return
		
	if is_player_bullet and body.is_in_group("enemies"):
		GameState.shots_hit += 1
		if body.has_method("die"):
			GameState.enemies_killed += 1
			body.die()
		queue_free()

	elif not is_player_bullet and body.is_in_group("player"):
		if body.has_method("die"):
			body.die()
		queue_free()
	
func _on_area_entered(area):
	if area.is_in_group("fences"):
		var dist = origin.distance_to(global_position)

		if dist < FENCE_GRACE_DISTANCE:
			return  # sale limpio, sin penalización

		if randf() < area.block_chance:
			queue_free()
