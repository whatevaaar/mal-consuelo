extends CharacterBody2D

enum State { IDLE, RUNNING, FLEE }
var state := State.IDLE

@export var speed := 60
@export var flee_speed := 90
@export var wander_radius := 64
@export var min_move_distance := 12

@export var idle_time_min := 0.5
@export var idle_time_max := 1.5

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle_timer: Timer = Timer.new()

var target_pos: Vector2
var map_rect: Rect2
var flee_dir := Vector2.ZERO


func _ready():
	add_to_group("animals")

	map_rect = get_viewport_rect()

	add_child(idle_timer)
	idle_timer.one_shot = true
	idle_timer.timeout.connect(_on_idle_timeout)

	GameState.phase_changed.connect(_on_phase_changed)

	_enter_idle()


func _physics_process(_delta):
	match state:
		State.IDLE:
			velocity = Vector2.ZERO

		State.RUNNING:
			_move_towards(target_pos, speed)

		State.FLEE:
			velocity = flee_dir * flee_speed
			_play_run(flee_dir)

	move_and_slide()

	# cuando ya salió de vista
	if state == State.FLEE and not map_rect.has_point(global_position):
		queue_free()


# ------------------------
# STATES
# ------------------------
func _enter_idle():
	state = State.IDLE
	velocity = Vector2.ZERO
	_play_idle()

	idle_timer.start(randf_range(idle_time_min, idle_time_max))


func _on_idle_timeout():
	_pick_new_target()


func _pick_new_target():
	state = State.RUNNING

	var attempts := 6
	for i in attempts:
		var angle = randf() * TAU
		var radius = randf_range(16, wander_radius)
		var candidate = global_position + Vector2(cos(angle), sin(angle)) * radius

		if map_rect.has_point(candidate) \
		and candidate.distance_to(global_position) > min_move_distance:
			target_pos = candidate
			return

	# fallback: si no encontró nada decente
	_enter_idle()


# ------------------------
# MOVIMIENTO
# ------------------------
func _move_towards(pos: Vector2, spd: float):
	var dir = pos - global_position

	if dir.length() < 4:
		_enter_idle()
		return

	dir = dir.normalized()
	velocity = dir * spd
	_play_run(dir)


# ------------------------
# ANIM
# ------------------------
func _play_run(dir: Vector2):
	anim.play("running")
	if abs(dir.x) > 0.1:
		anim.flip_h = dir.x < 0


func _play_idle():
	anim.play("idle")


# ------------------------
# FASES
# ------------------------
func _on_phase_changed(phase):
	if phase == GameState.Phase.NIGHT and state != State.FLEE:
		_enter_flee()


func _enter_flee():
	state = State.FLEE
	idle_timer.stop()

	var exits = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT
	]

	flee_dir = exits.pick_random()


# ------------------------
# VIDA
# ------------------------
func die():
	GameState.add_food(1)
	queue_free()
