extends Node2D

@export var enemy_scene: PackedScene = preload("res://Enemigos/enemigo.tscn")
@export var dialog_scene: PackedScene = preload("res://Dialog/dialog.tscn")

@export var spawn_timer_sec := 30.0
@export var phase_timer: Timer

@onready var player = $Player
@onready var enemies = $Enemies

@export var day_duration := 20.0    # segundos
@export var dusk_duration := 5.0
@export var night_duration := 15.0
@export var end_duration := 3.0




func _ready():
	var hud = preload("res://hud/HUD.tscn").instantiate()
	add_child(hud)
	
	var timer = Timer.new()
	timer.wait_time = spawn_timer_sec
	timer.autostart = true
	timer.one_shot = false
	
	phase_timer = Timer.new()
	phase_timer.one_shot = true
	phase_timer.timeout.connect(_on_phase_timeout)
	add_child(phase_timer)

	GameState.phase_changed.connect(_on_phase_changed)
	#GameState.day_changed.connect(_on_day_changed)
	GameState.game_ended.connect(_on_game_ending)

	_on_phase_changed(GameState.phase)
	show_dialog(["Día 1..."])
	timer.connect("timeout", Callable(self, "_spawn_enemy"))
	add_child(timer)

func _spawn_enemy():
	if not enemy_scene or GameState.phase != GameState.Phase.NIGHT:
		return
	var e = enemy_scene.instantiate()
	e.global_position = Vector2(randf_range(0, 200), randf_range(0, 200))  # dentro del mapa
	e.target = player
	e.add_to_group("enemies")
	enemies.add_child(e)
	show_dialog(["Ya vienen..."])

func show_dialog(lines: Array[String]):
	var dialog = dialog_scene.instantiate()
	dialog.lines = lines
	add_child(dialog)

func _on_phase_changed(phase):
	match phase:
		GameState.Phase.DAY:
			phase_timer.start(day_duration)
			show_dialog(["Día " + str(GameState.day)])
		GameState.Phase.DUSK:
			phase_timer.start(dusk_duration)
			show_dialog(["El sol cae sobre la tierra seca."])
		GameState.Phase.NIGHT:
			phase_timer.start(night_duration)
			show_dialog(["La noche no perdona."])
		GameState.Phase.END:
			phase_timer.start(end_duration)
func _on_phase_timeout():
	GameState.next_phase()
	
func _on_game_ending():
	if GameState.wounds >= 3:
		show_dialog(["La tierra reclamó lo que quedaba."])
	else:
		show_dialog(["El rancho sigue en pie, pero no hay a quién volver."])
