extends CanvasLayer

@onready var day_label := $Panel/HBoxContainer/DayLabel
@onready var nostalgia_label := $Panel/HBoxContainer/NostalgiaLabel
@onready var wounds_label := $Panel/HBoxContainer/WoundsLabel
@onready var hunger_label := $Panel/HBoxContainer/HungerLabel

func _ready():
	GameState.day_changed.connect(_update)
	GameState.stats_changed.connect(_update)
	_update()

func _update(_arg = null):
	day_label.text = "Día " + str(GameState.day)
	nostalgia_label.text = "Nostalgia: " + _bars(GameState.nostalgia)
	wounds_label.text = "Heridas: " + _bars(GameState.wounds)
	hunger_label.text = "Hambre: " + _bars(GameState.hunger)

func _bars(value: int) -> String:
	return "■".repeat(value)
