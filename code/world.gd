class_name World
extends Node2D

var area: Rect2i = Rect2i(0, 0, 15, 15)

var dancers: int = 25
var kill_range: int = 999
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
			$TileMapLayer.set_cell(pos, 0, tile)


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
		$Dancers.add_child(dancer)
	assign_controllers(["wasd", "arrows", "joy0", "joy1", "joy2", "joy3"])
	for dancer in $Dancers.get_children():
		print(dancer.controller)

func update_dancer(dancer: Dancer) -> void:
	var move_direction = dancer.move_random()
	if Global.has_controller(dancer.controller):
		dancer.is_player = true
		var mind: Global.Mind = Global.minds[dancer.controller]
		move_direction = Global.move_direction(dancer.controller)
		if mind.shoot:
			move_direction = Vector2i.ZERO
			shoot(dancer, mind.direction)
	if move_direction != Vector2i.ZERO:
		var new_pos: Vector2i = dancer.pos + move_direction
		move_dancer(dancer, new_pos)
	
func move_dancer(dancer: Dancer, new_pos: Vector2i) -> void:
	if occupied.has(new_pos) || !available.has_point(new_pos):
		return
	occupied.erase(dancer.pos)
	occupied[new_pos] = dancer
	dancer.pos = new_pos

func _on_tick_timeout() -> void:
	check_inputs()
	for dancer: Dancer in $Dancers.get_children():
		update_dancer(dancer)
	Global.clear_minds()

func assign_controllers(controllers: Array[String]) -> void:
	if controllers.is_empty():
		return
	var available_dancers: Array = $Dancers.get_children()
	available_dancers.shuffle()
	for new_dancer: Dancer in available_dancers:
		if new_dancer.controller == "":
			new_dancer.controller = controllers.pop_back()
			$Dancers.move_child(new_dancer, 0)
		if controllers.is_empty():
			return

func kill(victim: Dancer) -> void:
	occupied.erase(victim.pos)
	$DeathSound.play()
	if victim.controller != "":
		assign_controllers([victim.controller])
		Global.remove_mind(victim.controller)
	victim.die()
	victim.reparent($Corpses)


func _unhandled_input(_event: InputEvent) -> void:
	if $Tick.time_left < $Tick.wait_time / 2.0:
		check_inputs()
	#for shooter: Dancer in $Dancers.get_children():
		#var dir: Vector2i = shooter.move_direction()
		#var controller: String = shooter.controller
		#if controller != "" and Input.is_action_just_pressed("shoot_" + controller) and dir != Vector2i.ZERO:
			#shoot(shooter)


func shoot(shooter: Dancer, direction)->void:
	$GunSound.play()
	var dir: Vector2i = direction
	var p: Vector2i = shooter.pos
	p += dir
	for i in range(kill_range):
		if !area.has_point(p):
			break
		var victim: Dancer = occupied.get(p)
		if victim is Dancer:
			kill(victim)
			break
		p += dir



func check_inputs() -> void:
	for controller in ["wasd", "arrows", "joy0", "joy1", "joy2", "joy3"]:
		if Input.is_action_pressed("up_" + controller):
			Global.plan_direction(controller, Vector2i.UP)
		elif Input.is_action_pressed("down_" + controller):
			Global.plan_direction(controller, Vector2i.DOWN)
		if Input.is_action_pressed("left_" + controller):
			Global.plan_direction(controller, Vector2i.LEFT)
		if Input.is_action_pressed("right_" + controller):
			Global.plan_direction(controller, Vector2i.RIGHT)
		if Input.is_action_pressed("shoot_" + controller):
			Global.plan_shoot(controller)
