# Fence.gd
extends Node2D

@export var block_chance := 0.7
@export var player_collision_shape: CollisionShape2D
@export var bullet_area: Area2D

func _ready():
	add_to_group("fences")


func _on_area_entered(area):
	if area.is_in_group("fences"):
		if randf() < area.block_chance:
			queue_free()
