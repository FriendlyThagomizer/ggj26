@abstract class_name Entity
extends CharacterBody2D

var pos: Vector2i

func _ready() -> void:
	position = pos * Global.tile_size

func _process(delta: float) -> void:
	var target_position: Vector2 = pos * Global.tile_size
	var direction: Vector2 = target_position - position
	position += direction.normalized() * delta * Global.tile_size / (Global.tick_duration/2.0)

#func move_to(world: World, new_pos: Vector2i) -> void:
	#if !world.can_move(new_pos):
		#return
	#world.move(self, pos, new_pos)
	#pos = new_pos

@abstract func move_direction() -> Vector2i

@abstract func update(new_pos: Vector2i) -> void
