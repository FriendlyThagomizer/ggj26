extends Node

const tile_size: float = 128
const tick_duration: float = 1.5


var mind_directions: Dictionary[String, Vector2i] = {}

func _unhandled_input(_event: InputEvent) -> void:
	check_inputs()


func check_inputs() -> void:
	for controller in ["wasd", "arrows", "joy1"]:
		if Input.is_action_pressed("up_" + controller):
			mind_directions[controller] = Vector2i.UP
		elif Input.is_action_pressed("down_" + controller):
			mind_directions[controller] = Vector2i.DOWN
		if Input.is_action_pressed("left_" + controller):
			mind_directions[controller] = Vector2i.LEFT
		if Input.is_action_pressed("right_" + controller):
			mind_directions[controller] = Vector2i.RIGHT

func clear_minds() -> void:
	for controller in mind_directions.keys():
		mind_directions[controller] = Vector2.ZERO
