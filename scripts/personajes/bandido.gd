extends CharacterBody2D

var alive := true
signal clicked(enemy)

@onready var area := $Area2D  # tu Area2D dentro del body
@onready var animation_player = $AnimatedSprite2D

func _ready():
	add_to_group("enemigos")
	_play_idle()

	area.connect("input_event", Callable(self, "_on_area_input"))

func _play_idle()-> void:
	animation_player.play("idle")
	
func _play_muerto()-> void:
	animation_player.play("muerto")
	
func _on_area_input(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and alive:
		emit_signal("clicked", self)

func morir():
	_play_muerto()
	alive = false
