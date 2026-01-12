extends Node

signal phase_changed(phase)
signal day_changed(day)
signal game_ended
signal stats_changed
signal ammo_changed

enum Phase { DAY, DUSK, NIGHT, END }

const MAX_AMMO := 6

var ammo := MAX_AMMO
var day := 1
var max_days := 3
var phase := Phase.DAY

var food := 0
var wounds := 0
var nostalgia := 0      # salud mental (sube con recuerdos, baja con tiempo)
var hunger := 0 

var enemies_killed := 0
var shots_fired := 0
var shots_hit := 0
var time_alive := 0.0
var cause_of_death := ""

func _ready() -> void:
	reset()

func accuracy() -> float:
	if shots_fired == 0:
		return 0.0
	return float(shots_hit) / shots_fired

func reset():
	day = 1
	phase = Phase.DAY
	food = 0
	wounds = 0
	emit_signal("day_changed", day)
	emit_signal("phase_changed", phase)

func next_phase():
	match phase:
		Phase.DAY:
			phase = Phase.DUSK
		Phase.DUSK:
			phase = Phase.NIGHT
		Phase.NIGHT:
			resolve_night()
			phase = Phase.END
		Phase.END:
			next_day()
			return

	emit_signal("phase_changed", phase)

func resolve_night():
	if hunger > 0:
		wounds += 1

	hunger += 1  # siempre amanece con más hambre
	emit_signal("stats_changed")

func next_day():
	day += 1
	if day > max_days:
		emit_signal("game_ended")
	else:
		phase = Phase.DAY
		emit_signal("day_changed", day)
		emit_signal("phase_changed", phase)

func add_food(amount := 1):
	var temp_hunger = hunger
	hunger = max(hunger - amount, 0)
	food += max(amount - temp_hunger, 0)
	emit_signal("stats_changed")

func add_nostalgia(amount := 1):
	nostalgia += amount
	emit_signal("stats_changed")

func add_wound(amount := 1):
	wounds += amount
	emit_signal("stats_changed")

func can_shoot() -> bool:
	return ammo > 0

func spend_ammo():
	if ammo <= 0:
		return false
	ammo -= 1
	ammo_changed.emit(ammo)
	return true
