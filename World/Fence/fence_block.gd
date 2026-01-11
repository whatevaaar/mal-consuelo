extends StaticBody2D

@export var block_chance := 0.7

func _ready():
	add_to_group("fences")
