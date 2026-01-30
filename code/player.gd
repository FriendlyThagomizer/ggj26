extends CharacterBody2D

@export var speed: float = 200
var next_direction = Vector2(0, 0)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("north"):
		next_direction = Vector2.UP
	elif Input.is_action_just_pressed("west"):
		next_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("south"):
		next_direction = Vector2.DOWN
	elif Input.is_action_just_pressed("east"):
		next_direction = Vector2.RIGHT
	

func _on_tick_timeout() -> void:
	position += next_direction * Global.tile_size
	next_direction = Vector2.ZERO
