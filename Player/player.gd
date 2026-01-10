extends CharacterBody2D

@export var bullet_scene: PackedScene = preload("res://Bala/bala.tscn")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var frames: SpriteFrames = anim.sprite_frames

const SPEED := 120

enum State { IDLE, WALK, SHOOT }
var state := State.IDLE

func _physics_process(_delta):
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
	if event is InputEventMouseButton and event.pressed:
		_play_shoot()
		shoot(get_global_mouse_position())

	if event is InputEventScreenTouch and event.pressed:
		_play_shoot()
		shoot(event.position)


func shoot(target_pos: Vector2):
	if not bullet_scene:
		return
	var b = bullet_scene.instantiate()
	b.global_position = global_position
	b.direction = (target_pos - global_position).normalized()
	anim.flip_h = b.direction[0]< 0
	b.is_player_bullet = true
	get_parent().get_node("Bullets").add_child(b)

func _play_walk(dir: Vector2):
	anim.play("walking")

	# Flip horizontal
	if abs(dir.x) > 0.1:
		anim.flip_h = dir.x < 0
		

func _play_idle():
	anim.stop()
	anim.play("idle")


func _play_shoot():
	if frames.has_animation("shooting"):
		state = State.SHOOT
		anim.play("shooting")
		
func _on_shoot_finished():
	state = State.IDLE
