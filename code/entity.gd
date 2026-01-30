class_name Entity
extends CharacterBody2D

var pos: Vector2i

func _ready() -> void:
	position = pos * Global.tile_size

func _process(delta: float) -> void:
	var target_position: Vector2 = pos * Global.tile_size
	var direction: Vector2 = target_position - position
	position += direction.normalized() * delta * Global.tile_size / (Global.tick_duration/2.0)
