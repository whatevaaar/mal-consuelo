extends CharacterBody2D

#Señales
signal clicked(enemy)

#Nodos
@onready var ray := $RayCast2D
@onready var screen_notifier := $VisibleOnScreenNotifier2D
@onready var aim_timer := $Timer

#Propiedades
@export var duelo := false
@export var speed := 80.0
@export var rango_disparo := 280.0

@export var rango_min := 20.0
@export var rango_ideal := 240.0
@export var rango_max := 280.0

var vivo := true
var jugador: Node2D
var apuntando := false
var puede_disparar := false

#Colisiones
@onready var area := $Area2D

#Animaciones
@onready var animation_jugador = $AnimatedSprite2D

#Balas
@onready var bullet_scene := preload("res://escenas/objetos/bala.tscn")
@onready var bullet_spawn := $BulletSpawn

func _ready():
	add_to_group("enemigos")
	_play_idle()
	
	jugador = get_tree().get_first_node_in_group("jugador")
	area.input_event.connect(_on_area_input)
	aim_timer.timeout.connect(_on_apuntado_completo)

func _process(_delta):
	if not vivo or jugador == null or not jugador.vivo:
		return

	ray.target_position = ray.to_local(jugador.global_position)
	ray.force_raycast_update()

	var ve_jugador: bool= ray.is_colliding() and ray.get_collider() == jugador
	var es_visible :bool = screen_notifier.is_on_screen()

	if es_visible and ve_jugador:
		_intentar_apuntar()
	else:
		_cancelar_apuntado()

	if not duelo:
		_mover_comportamiento(ve_jugador)

func _mover_comportamiento(ve_jugador: bool):
	if not ve_jugador or not vivo:
		velocity = Vector2.ZERO
		return

	var dist := global_position.distance_to(jugador.global_position)
	var dir := (jugador.global_position - global_position).normalized()

	if puede_disparar:
		velocity = Vector2.ZERO

	elif dist > rango_max:
		velocity = dir * speed

	elif dist < rango_min:
		velocity = -dir * speed * 0.4

	else:
		# rango bueno
		velocity = Vector2.ZERO

	move_and_slide()

#Disparos
func _on_apuntado_completo():
	puede_disparar = true
	if jugador and jugador.vivo and vivo:
		_disparar_bala()

func _intentar_apuntar():
	if apuntando or puede_disparar:
		return

	apuntando = true
	aim_timer.start()

func _cancelar_apuntado():
	if apuntando:
		aim_timer.stop()
	apuntando = false
	puede_disparar = false

func _disparar_bala():
	if not puede_disparar:
		return

	var bala = bullet_scene.instantiate()
	bala.global_position = global_position
	bala.velocity = (jugador.global_position - global_position).normalized() * bala.speed
	bala.tirador = self
	get_tree().current_scene.add_child(bala)

	puede_disparar = false
	apuntando = false

#Animaciones
func _play_idle()-> void:
	animation_jugador.play("idle")
	
func _play_muerto()-> void:
	animation_jugador.play("muerto")
	
func _on_area_input(_viewport, event, _shape_idx):
	if event.is_action_pressed("click") and vivo:
		emit_signal("clicked", self)

#FIn
func morir():
	_play_muerto()
	vivo = false
