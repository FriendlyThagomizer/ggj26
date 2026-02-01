class_name Dancer
extends Node2D

var dead: bool = false
var death_fade: float = 0.0 
var is_player: bool = false
var has_moved: bool = false
var kills: int = 0

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
	preload("res://art/Characters/Masks/Star_mask_1.png"),
	preload("res://art/Characters/Masks/Star_mask_2.png"),
	preload("res://art/Characters/Masks/Star_mask_3.png"),
	preload("res://art/Characters/Masks/Star_mask_4.png"),
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
		%Mask.modulate.a = min(1, %Mask.modulate.a + delta / Global.tick_duration)
		%OldMask.modulate.a = max(0, %OldMask.modulate.a - delta / Global.tick_duration)
	else:
		
		death_fade += delta
		if is_player:
			%Skull.visible = true
			%Skull.modulate.a = death_fade
			%Mask.modulate.a = 1.0 - min(death_fade, 1) * 0.7
			%OldMask.visible = false
		$Origin.rotation_degrees = min(death_fade * 5 * 90, 90)
		%BloodPool.visible = true
		%BloodPool.modulate.a = clamp(death_fade, 0.3, 1.3)-0.3 


func die() -> void:
	dead = true
	#rotation_degrees = 90

func move_random() -> Vector2i:
	return npc_directions.pick_random()

func get_mask() -> Texture2D:
	return %Mask.texture

func change_mask_to(texture: Texture2D):
	%OldMask.visible = true
	%OldMask.texture = %Mask.texture
	%OldMask.modulate.a = 1.0
	%Mask.texture = texture
	%Mask.modulate.a = 0.0

#func move_direction() -> Vector2i:
	#if Global.has_controller(controller):
	##if Global.mind_directions.has(controller):
		#is_player = true
		#return Global.move_direction(controller)
	#else:
		#return npc_directions.pick_random()
