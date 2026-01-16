extends CharacterBody2D

#Constantes
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

#Propiedades
var alive := true
var apuntando:= false
var current_target = null

#Balas
@onready var bullet_scene := preload("res://escenas/objetos/bala.tscn")
@onready var bullet_spawn := $BulletSpawn
@onready var punteria := $Punteria

#Sprite
@onready var animation_player = $AnimatedSprite2D

	
func _ready() -> void:
	_play_idle()
	add_to_group("jugador")
	await get_tree().process_frame
	for enemy in get_tree().get_nodes_in_group("enemigos"):
		enemy.connect("clicked", Callable(self, "_on_enemy_clicked"))

func _play_disparo()-> void:
	animation_player.play("disparo")

func _play_idle()-> void:
	animation_player.play("idle")
	
func _physics_process(_delta: float) -> void:
	if apuntando:
		return
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_enemy_clicked(enemy):
	if not alive or apuntando:
		return
	current_target = enemy
	apuntando = true
	_play_disparo()
	
	punteria.activate()
	punteria.connect("resolved", Callable(self, "_on_punteria_resolved"), CONNECT_ONE_SHOT)

func _on_punteria_resolved(success: bool):
	apuntando = false
	punteria.hide()

	if current_target:
		_disparar_bala(success)

	current_target = null

func _disparar_bala(success: bool):
	var bala = bullet_scene.instantiate()
	bala.global_position = bullet_spawn.global_position
	bala.velocity = (get_global_mouse_position() - global_position).normalized() * bala.speed
	bala.tirador = self
	get_tree().current_scene.add_child(bala)


func morir():
	alive = false
	queue_free()
