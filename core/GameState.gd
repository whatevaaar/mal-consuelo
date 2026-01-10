extends Node

signal phase_changed(phase)
signal day_changed(day)
signal game_ended
signal stats_changed

enum Phase { DAY, DUSK, NIGHT, END }

var day := 1
var max_days := 3
var phase := Phase.DAY

var food := 0
var wounds := 0
var nostalgia := 0      # salud mental (sube con recuerdos, baja con tiempo)
var hunger := 0 

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
	hunger = max(hunger - amount, 0)
	emit_signal("stats_changed")

func add_nostalgia(amount := 1):
	nostalgia += amount
	emit_signal("stats_changed")

func add_wound(amount := 1):
	wounds += amount
	emit_signal("stats_changed")
