class_name World
extends Node2D

var area: Rect2i = Rect2i(0, 0, 32, 20)

var available: Rect2i = area.grow(-1)
var occupied: Dictionary[Vector2i, Node2D] = {}

func _ready() -> void:
	build_tiles()
	place_players()
	place_npcs()
	$Tick.wait_time = Global.tick_duration
	$Tick.start()

func build_tiles() -> void:
	$TileMapLayer.clear()
	for y: int in range(area.position.y, area.end.y):
		for x: int in range(area.position.x, area.end.x):
			var pos: Vector2i = Vector2i(x, y)
			var tile: Vector2i = Vector2i(0, 0)
			if !available.has_point(pos):
				tile = Vector2i(1, 0)
			$TileMapLayer.set_cell(pos, 1, tile)
				


func random_pos() -> Vector2i:
	return Vector2i(randi_range(available.position.x, available.end.x-1), randi_range(available.position.y, available.end.y-1))

func random_free_pos() -> Vector2i:
	while true:
		var pos: Vector2i = random_pos()
		if !occupied.has(pos):
			return pos
	return Vector2i(-1, -1)

func place_players() -> void:
	var player: Player = preload("res://scenes/player.tscn").instantiate()
	player.pos = random_free_pos()
	occupied[player.pos] = player
	$Players.add_child(player)

func place_npcs() -> void:
	for i in 80:
		var npc: Npc = preload("res://scenes/npc.tscn").instantiate()
		npc.pos = random_free_pos()
		occupied[npc.pos] = npc
		$Npcs.add_child(npc)

#func can_move(pos: Vector2i) -> bool:
	#return available.has_point(pos) && !occupied.has(pos)

func move_entity(entity: Entity) -> void:
	var new_pos: Vector2i = entity.pos + entity.move_direction()
	if occupied.has(new_pos) || !available.has_point(new_pos):
		return
	occupied.erase(entity.pos)
	occupied[new_pos] = entity
	entity.pos = new_pos
	entity.update(new_pos)

func _on_tick_timeout() -> void:
	for player: Player in $Players.get_children():
		move_entity(player)
		#player.tick(self)
	for npc: Npc in $Npcs.get_children():
		move_entity(npc)
		#npc.tick(self)
