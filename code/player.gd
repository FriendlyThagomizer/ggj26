class_name Player
extends Entity

@export var speed: float = 200
var next_direction: Vector2i = Vector2i(0, 0)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("north"):
		next_direction = Vector2i.UP
	elif Input.is_action_pressed("west"):
		next_direction = Vector2i.LEFT
	elif Input.is_action_pressed("south"):
		next_direction = Vector2i.DOWN
	elif Input.is_action_pressed("east"):
		next_direction = Vector2i.RIGHT

func tick(world: World) -> void:
	#position += next_direction * Global.tile_size
	pos += next_direction
	next_direction = Vector2i.ZERO
