class_name Dancer
extends Node2D

const npc_directions: Array[Vector2i] = [
	Vector2i.DOWN,
	Vector2i.UP,
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.ZERO,
	Vector2i.ZERO,
	Vector2i.ZERO,
	Vector2i.ZERO
]

var controller: String = ""

var pos: Vector2i

func _ready() -> void:
	position = pos * Global.tile_size

func _process(delta: float) -> void:
	var target_position: Vector2 = pos * Global.tile_size
	var direction: Vector2 = target_position - position
	position += direction.normalized() * delta * Global.tile_size / (Global.tick_duration/2.0)


func move_direction() -> Vector2i:
	if Global.mind_directions.has(controller):
		return Global.mind_directions[controller]
	else:
		return npc_directions.pick_random()
