extends CharacterBody2D

@export var bullet_scene: PackedScene = preload("res://World/Bala/bala.tscn")
@export var end_screen_scene: PackedScene

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var frames: SpriteFrames = anim.sprite_frames

const SPEED := 120
const MAX_HUNGER := 3

enum State { IDLE, WALK, SHOOT, DEAD }
var state := State.IDLE
var can_input := true

signal died

func _ready() -> void:
	add_to_group("player")
	GameState.stats_changed.connect(_update)
	
func _update():
	if GameState.hunger >= MAX_HUNGER:
		GameState.cause_of_death = "hunger"
		die()
	

func _physics_process(_delta):
	if state == State.DEAD:
		return

	if not can_input:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if dir.length() > 0:
		dir = dir.normalized()
		velocity = dir * SPEED
		state = State.WALK
		_play_walk(dir)
	else:
		velocity = Vector2.ZERO
		if state != State.SHOOT:
			state = State.IDLE
			_play_idle()

	move_and_slide()


func _input(event):
	if state == State.DEAD:
		return

	if event is InputEventMouseButton and event.pressed:
		_play_shoot()
		shoot(get_global_mouse_position())

	if event is InputEventScreenTouch and event.pressed:
		_play_shoot()
		shoot(event.position)


func shoot(target_pos: Vector2):
	if not bullet_scene:
		return

	if not GameState.can_shoot():
		return

	GameState.spend_ammo()

	var b = bullet_scene.instantiate()
	b.global_position = global_position
	b.direction = (target_pos - global_position).normalized()
	b.is_player_bullet = true
	get_parent().get_node("Bullets").add_child(b)


func _play_walk(dir: Vector2):
	anim.play("walking")
	if abs(dir.x) > 0.1:
		anim.flip_h = dir.x < 0


func _play_idle():
	anim.play("idle")


func _play_dead():
	anim.play("dead")


func _play_shoot():
	if state == State.DEAD:
		return

	if frames.has_animation("shooting"):
		state = State.SHOOT
		anim.play("shooting")
		if not anim.animation_finished.is_connected(_on_shoot_finished):
			anim.animation_finished.connect(_on_shoot_finished, CONNECT_ONE_SHOT)

func _on_shoot_finished():
	if state != State.DEAD:
		state = State.IDLE

func die():
	if state == State.DEAD:
		return

	state = State.DEAD
	can_input = false
	velocity = Vector2.ZERO
	emit_signal("died")
	_play_dead()
