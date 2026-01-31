class_name Dancer
extends Node2D

var dead: bool = false
var death_fade: float = 0.0 

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
static var masks: Array[Resource] = [
	preload("res://art/Characters/Masks/Moon_mask_1.png"),
	preload("res://art/Characters/Masks/Moon_mask_2.png"),
	preload("res://art/Characters/Masks/Moon_mask_3.png"),
	preload("res://art/Characters/Masks/Moon_mask_4.png"),
	preload("res://art/Characters/Masks/Sun_mask_1.png"),
	preload("res://art/Characters/Masks/Sun_mask_2.png"),
	preload("res://art/Characters/Masks/Sun_mask_3.png"),
	preload("res://art/Characters/Masks/Sun_mask_4.png"),
]

var controller: String = ""

var pos: Vector2i

func _ready() -> void:
	position = pos * Global.tile_size
	#var masks: PackedS
	%Mask.texture = masks.pick_random()

func _process(delta: float) -> void:
	if !dead:
		var speed: float = Global.tile_size / (Global.tick_duration / 2.0)
		var target_position: Vector2 = pos * Global.tile_size
		var direction: Vector2 = target_position - position
		if direction.length() < speed * delta:
			position = target_position
		else:
			position += direction.normalized() * delta * speed
	elif death_fade < 1.0:
		death_fade += delta
		if controller != "":
			%Skull.visible = true
			%Skull.modulate.a = death_fade
			%Mask.modulate.a = 1.0 - death_fade * 0.7
		$Origin.rotation_degrees = min(death_fade * 5 * 90, 90)

func die() -> void:
	dead = true
	#rotation_degrees = 90

func move_direction() -> Vector2i:
	if Global.mind_directions.has(controller):
		return Global.mind_directions[controller]
	else:
		return npc_directions.pick_random()
