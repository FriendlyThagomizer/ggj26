extends Node

const tile_size: float = 128
const tick_duration: float = 1.5


class Mind extends RefCounted:
	var direction: Vector2i = Vector2.ZERO
	var shoot: bool = false
	
	func clear() -> void:
		direction = Vector2i.ZERO
		shoot = false

var minds: Dictionary[String, Mind] = {}

func remove_mind(controller: String) -> void:
	minds.erase(controller)

func plan_direction(controller: String, direction: Vector2i) -> void:
	if !minds.has(controller):
		minds[controller] = Mind.new()
	minds[controller].direction = direction

func plan_shoot(controller: String) -> void:
	if !minds.has(controller):
		minds[controller] = Mind.new()
	minds[controller].shoot = true

func clear_minds() -> void:
	#return
	for controller in minds.keys():
		minds[controller].clear()

func has_controller(controller: String) -> bool:
	return minds.has(controller)

func move_direction(controller: String) -> Vector2i:
	var mind: Mind = minds[controller]
	if mind.shoot:
		return Vector2i.ZERO
	else:
		return mind.direction
	
