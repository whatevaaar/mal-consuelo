extends Node

@export var chance := 0.6        # probabilidad de que aparezca texto
@export var cooldown_sec := 6.0  # tiempo mínimo entre frases

var _last_time := -999.0
var _last_phrase := ""

# =========================
# BANCO DE FRASES
# =========================

var PHRASES := {
	"day_start": [
		"El sol vuelve a salir. No pregunta nada.",
		"Otro día. El rancho sigue aquí.",
		"Amanece. El silencio también."
	],

	"night_start": [
		"De noche no vienen por palabras.",
		"La oscuridad siempre trae algo.",
		"Es cuando empiezan los ruidos."
	],

	"hunger_high": [
		"El estómago se acostumbra. El cuerpo no.",
		"Trabajar con hambre es trabajar lento.",
		"La tierra no da nada gratis."
	],

	"wounds_high": [
		"La sangre se seca rápido.",
		"Cada paso pesa más.",
		"El cuerpo recuerda los golpes."
	],

	"nostalgia_high": [
		"El recuerdo arde más que el sol.",
		"Antes no dolía así.",
		"Algunas voces no se callan."
	]
}

# =========================
# READY
# =========================

func _ready():
	randomize()
	GameState.day_changed.connect(_on_day_changed)
	GameState.stats_changed.connect(_on_stats_changed)
	GameState.phase_changed.connect(_on_phase_changed)

# =========================
# EVENTOS
# =========================

func _on_day_changed(_day: int):
	say("day_start")

func _on_phase_changed(phase):
	if phase == GameState.Phase.NIGHT:
		say("night_start")

func _on_stats_changed():
	if GameState.hunger >= 3:
		say("hunger_high")

	if GameState.wounds >= 2:
		say("wounds_high")

	if GameState.nostalgia >= 3:
		say("nostalgia_high")

# =========================
# CORE
# =========================

func say(tag: String):
	if not PHRASES.has(tag):
		return

	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_time < cooldown_sec:
		return

	if randf() > chance:
		return

	_last_time = now

	var line := _pick_unique(PHRASES[tag])
	_show_dialog(line)

func _pick_unique(lines: Array) -> String:
	var pick :String = lines.pick_random()
	if pick == _last_phrase and lines.size() > 1:
		pick = lines.pick_random()
	_last_phrase = pick
	return pick

# =========================
# UI
# =========================

func _show_dialog(text: String):
	var dialog := preload("res://Dialog/dialog.tscn").instantiate()
	dialog.lines = [text]
	get_tree().current_scene.add_child(dialog)
