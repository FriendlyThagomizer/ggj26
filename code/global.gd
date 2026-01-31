extends Node

const tile_size: float = 128
const tick_duration: float = 2


var mind_directions: Array[Vector2i] = [Vector2i.ZERO]

func _unhandled_input(event: InputEvent) -> void:
	check_inputs()


func check_inputs() -> void:
	if Input.is_action_pressed("north"):
		mind_directions[0] = Vector2i.UP
	elif Input.is_action_pressed("west"):
		mind_directions[0] = Vector2i.LEFT
	elif Input.is_action_pressed("south"):
		mind_directions[0] = Vector2i.DOWN
	elif Input.is_action_pressed("east"):
		mind_directions[0] = Vector2i.RIGHT
