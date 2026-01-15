extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var alive := true
var apuntando:= false
var current_target = null

@onready var punteria := $Punteria
	
func _ready() -> void:
	await get_tree().process_frame
	for enemy in get_tree().get_nodes_in_group("enemigos"):
		enemy.connect("clicked", Callable(self, "_on_enemy_clicked"))

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
	if not alive:
		return
	current_target = enemy
	apuntando = true
	punteria.activate()
	punteria.connect("resolved", Callable(self, "_on_punteria_resolved"), CONNECT_ONE_SHOT)

func _on_punteria_resolved(success: bool):
	apuntando = false
	punteria.hide()
	if success and current_target:
		current_target.die()
	current_target = null

func die():
	alive = false
	queue_free()
