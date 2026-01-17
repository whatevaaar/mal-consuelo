extends CharacterBody2D

#Señales
signal muerte

#Constantes
const SPEED = 60.0
const JUMP_VELOCITY = -400.0

#Propiedades
var vivo := true
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

func _physics_process(_delta: float) -> void:
	if apuntando or not vivo:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var x := Input.get_action_strength("derecha") - Input.get_action_strength("izquierda")
	var y := Input.get_action_strength("abajo") - Input.get_action_strength("arriba")

	var dir := Vector2(x, y)

	# FLIP según dirección X
	if dir.x != 0:
		animation_player.flip_h = dir.x < 0

	if dir != Vector2.ZERO:
		velocity = dir.normalized() * SPEED
		_play_caminando()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		_play_idle()

	move_and_slide()


#Animaciones
func _play_disparo()-> void:
	animation_player.play("disparo")

func _play_idle()-> void:
	if animation_player.animation != "idle":
		animation_player.play("idle")
	
func _play_muerte()-> void:
	animation_player.play("muerte")

func _play_caminando()-> void:
	if animation_player.animation != "caminando":
		animation_player.play("caminando")


#Apuntar y disparar
func _on_enemy_clicked(enemy):
	if not vivo or apuntando:
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


#Pa acá vamos todos
func morir():
	vivo = false
	_play_muerte()
	emit_signal("muerte")
