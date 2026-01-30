extends CharacterBody2D


const directions: Array[Vector2] = [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]

func tick() -> void:
	var direction: Vector2 = directions.pick_random()
	position += direction * Global.tile_size
