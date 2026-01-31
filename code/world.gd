class_name World
extends Node2D

var area: Rect2i = Rect2i(0, 0, 32, 20)
var dancers = 10
var available: Rect2i = area.grow(-1)
var occupied: Dictionary[Vector2i, Node2D] = {}

func _ready() -> void:
	build_tiles()
	place_dancers()
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


func place_dancers() -> void:
	for i in dancers:
		var dancer: Dancer = preload("res://scenes/dancer.tscn").instantiate()
		dancer.pos = random_free_pos()
		occupied[dancer.pos] = dancer
		if i == 0:
			dancer.controller = "wasd"
		elif i==1:
			dancer.controller = "arrows"
		elif i==2:
			dancer.controller = "joy1"
		$Dancers.add_child(dancer)


func move_dancer(dancer: Dancer) -> void:
	var new_pos: Vector2i = dancer.pos + dancer.move_direction()
	if occupied.has(new_pos) || !available.has_point(new_pos):
		return
	occupied.erase(dancer.pos)
	occupied[new_pos] = dancer
	dancer.pos = new_pos

func _on_tick_timeout() -> void:
	Global.check_inputs()
	for dancer: Dancer in $Dancers.get_children():
		move_dancer(dancer)
	Global.clear_minds()
		
