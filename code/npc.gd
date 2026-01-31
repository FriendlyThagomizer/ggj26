class_name Npc
extends Entity

const directions: Array[Vector2i] = [
	Vector2i.DOWN,
	Vector2i.UP,
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.ZERO,
	Vector2i.ZERO,
	Vector2i.ZERO,
	Vector2i.ZERO
]

#func tick(world: World) -> void:
	#var direction: Vector2i = directions.pick_random()
	#pos += direction


func move_direction() -> Vector2i:
	return directions.pick_random()


func update(new_pos: Vector2i) -> void:
	pass
