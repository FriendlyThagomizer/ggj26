extends Node

const tile_size: float = 128
const tick_duration: float = 1.5


var mind_directions: Dictionary[String, Vector2i] = {}


func clear_minds() -> void:
	#return
	for controller in mind_directions.keys():
		mind_directions[controller] = Vector2.ZERO
