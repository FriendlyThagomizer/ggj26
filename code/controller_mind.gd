class_name ControllerMind
extends RefCounted

var controller: String

func _init(controller: String) -> void:
	self.controller = controller

func move_direction() -> Vector2i:
	return Global.mind_directions[controller]
