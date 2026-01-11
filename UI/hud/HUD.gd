extends CanvasLayer

@onready var container := $Panel/HBoxContainer

# definición de lo que el HUD muestra
var stats := [
	{
		"id": "food",
		"label": "Comida",
		"mode": "number"
	},
	{
		"id": "hunger",
		"label": "Hambre",
		"mode": "bars",
		"max": 6
	},
	{
		"id": "ammo",
		"label": "Balas",
		"mode": "bars",
		"max": GameState.MAX_AMMO
	}
]

var labels := {}  # id → RichTextLabel

func _ready():
	_build_hud()

	GameState.ammo_changed.connect(_update)
	GameState.stats_changed.connect(_update)

	_update()


# ------------------------
# CONSTRUCCIÓN
# ------------------------
func _build_hud():
	for stat in stats:
		var rtl := RichTextLabel.new()
		rtl.fit_content = true
		rtl.scroll_active = false
		rtl.bbcode_enabled = true
		rtl.custom_minimum_size.x = 120

		container.add_child(rtl)
		labels[stat.id] = rtl


# ------------------------
# UPDATE
# ------------------------
func _update(_arg = null):
	for stat in stats:
		var id = stat.id
		var rtl: RichTextLabel = labels[id]

		match id:
			"food":
				rtl.text = "[b]%s: %d" % [stat.label, GameState.food]

			"hunger":
				rtl.text = "[b]%s: %s" % [
					stat.label,
					_bars(GameState.hunger, stat.max)
				]

			"ammo":
				rtl.text = "[b]%s: %s" % [
					stat.label,
					_bars(GameState.ammo, stat.max)
				]


# ------------------------
# HELPERS
# ------------------------
func _bars(value: int, max: int) -> String:
	return "■".repeat(value) + "□".repeat(max - value)
