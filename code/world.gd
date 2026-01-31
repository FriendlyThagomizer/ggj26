class_name World
extends Node2D

var area: Rect2i = Rect2i(0, 0, 28, 20)

var dancers: int = 5
var available: Rect2i = area.grow(-1)
var occupied: Dictionary[Vector2i, Node2D] = {}

func _ready() -> void:
	build_tiles()
	place_dancers()
	$Tick.wait_time = Global.tick_duration
	$Tick.start()
	$AudioStreamPlayer.play()

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
			dancer.controller = "joy0"
		elif i==3:
			dancer.controller = "joy1"
		elif i==4:
			dancer.controller = "joy2"
		elif i==5:
			dancer.controller = "joy3"
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

func kill(victim: Dancer) -> void:
	occupied.erase(victim.pos)
	$DeathSound.play()
	if victim.controller != "":
		var available_dancers: Array = $Dancers.get_children()
		available_dancers.shuffle()
		for new_dancer: Dancer in available_dancers:
			if new_dancer.controller == "":
				new_dancer.controller = victim.controller
				break
		Global.mind_directions.erase(victim.controller)
	victim.reparent($Corpses)
	victim.rotation_degrees = 90


func _unhandled_input(_event: InputEvent) -> void:
	for shooter: Dancer in $Dancers.get_children():
		var dir: Vector2i = shooter.move_direction()
		var controller: String = shooter.controller
		if controller != "" and Input.is_action_just_pressed("shoot_" + controller) and dir != Vector2i.ZERO:
			shoot(shooter)
			
func shoot(shooter: Dancer)->void:
	$GunSound.play()
	var dir: Vector2i = shooter.move_direction()
	var p: Vector2i = shooter.pos
	p += dir
	while area.has_point(p):
		var victim: Dancer = occupied.get(p)
		if victim is Dancer:
			kill(victim)
			break
		p += dir
