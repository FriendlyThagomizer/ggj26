class_name World
extends Node2D

var area: Rect2i = Rect2i(0, 0, 15, 15)

var dancers: int = 30
var switch_chance: float = 0.5
var kill_range: int = 1
var available: Rect2i = area.grow(-1)
var occupied: Dictionary[Vector2i, Node2D] = {}
var pause_ticks = 0
var should_restart: bool = false

func _ready() -> void:
	build_tiles()
	place_dancers()
	$Tick.wait_time = Global.tick_duration
	$Tick.start()
	$AudioStreamPlayer.play()

func build_tiles() -> void:
	#$TileMapLayer.clear()
	for y: int in range(area.position.y, area.end.y):
		for x: int in range(area.position.x, area.end.x):
			var pos: Vector2i = Vector2i(x, y)
			$FloorLayer.set_cell(pos, 0, [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)].pick_random())
			var tile: Vector2i = Vector2i(2, 1)
			if x == 0:
				tile.x = 1
			if x == area.end.x - 1:
				tile.x = 3
			if y == 0:
				tile.y = 0
			if y == area.end.y-1:
				tile.y = 2
			if tile != Vector2i(2, 1):
				$WallLayer.set_cell(pos, 0, tile)


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

func update_dancer(dancer: Dancer) -> void:
	if dancer.has_moved:
		dancer.has_moved = false
		return
	var move_direction = dancer.move_random()
	if Global.has_controller(dancer.controller):
		dancer.is_player = true
		var mind: Global.Mind = Global.minds[dancer.controller]
		move_direction = Global.move_direction(dancer.controller)
		if mind.shoot:
			move_direction = Vector2i.ZERO
			shoot(dancer, mind.direction)
	if move_direction != Vector2i.ZERO && !dancer.dead:
		var new_pos: Vector2i = dancer.pos + move_direction
		move_dancer(dancer, new_pos)
	
func move_dancer(dancer: Dancer, new_pos: Vector2i) -> void:
	if !available.has_point(new_pos):
		return
	if occupied.has(new_pos):
		var partner: Dancer = occupied[new_pos]
		if partner.get_index() > dancer.get_index() && !partner.has_moved && partner.controller == "" && randf() < switch_chance:
			partner.has_moved = true
			occupied[partner.pos] = dancer
			occupied[dancer.pos] = partner
			partner.pos = dancer.pos
			dancer.pos = new_pos
			var partner_mask: Texture2D = partner.get_mask()
			partner.change_mask_to(dancer.get_mask())
			dancer.change_mask_to(partner_mask)
		return
	occupied.erase(dancer.pos)
	occupied[new_pos] = dancer
	dancer.pos = new_pos

func _on_tick_timeout() -> void:
	if pause_ticks > 0:
		pause_ticks -= 1
		return
	if should_restart:
		Global.reset()
		for dancer: Dancer in $Dancers.get_children():
			dancer.queue_free()
		for corpse: Dancer in $Corpses.get_children():
			corpse.queue_free()
		occupied = {}
		place_dancers()
		should_restart = false
		%GameOver.hide()
		return
	check_inputs()
	for dancer: Dancer in $Dancers.get_children():
		update_dancer(dancer)
	Global.clear_minds()
	var players: Array[Dancer] = living_players()
	if ($Corpses.get_child_count() > 0 && players.is_empty()) || (players.size() == 1 && players[0].kills > 0):
		end_round(players)
	highlight_doubled_rows()

func end_round(players: Array[Dancer]) -> void:
	%GameOver.visible = true
	if players.is_empty():
		%WhoWon.text = "All players died"
	else:
		%WhoWon.text = Global.player_names[players[0].controller] + " won"
	pause_ticks = 4
	should_restart = true
	
func living_players() -> Array[Dancer]:
	var players: Array[Dancer] = []
	for dancer: Dancer in $Dancers.get_children():
		if Global.has_controller(dancer.controller):
			players.append(dancer)
	return players
	

func highlight_doubled_rows():
	var rows: Dictionary[int, int] = {}
	var columns: Dictionary[int, int] = {}
	for dancer: Dancer in $Dancers.get_children():
		if Global.has_controller(dancer.controller):
			rows[dancer.pos.y] = rows.get(dancer.pos.y, 0) + 1
			columns[dancer.pos.x] = columns.get(dancer.pos.x, 0) + 1
	for y: int in rows.keys():
		if rows[y] >= 2:
			for x in range(available.position.x, available.end.x):
				highlight(Vector2i(x, y))
	for x: int in columns.keys():
		if columns[x] >= 2:
			for y in range(available.position.y, available.end.y):
				highlight(Vector2i(x, y))
	#highlight(Vector2i(randi_range(1, 10), randi_range(1, 10)))

func highlight(pos: Vector2i) -> void:
	var hl: Node2D = preload("res://scenes/highlight.tscn").instantiate()
	hl.position = pos * Global.tile_size
	$Highlights.add_child(hl)

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
	if !controllers.is_empty():
		print("can't assign all")

func kill(victim: Dancer) -> void:
	#occupied.erase(victim.pos)
	for pos in occupied.keys():
		if occupied[pos] == victim:
			occupied.erase(pos)
	$DeathSound.play()
	if victim.controller != "":
		#assign_controllers([victim.controller])
		Global.remove_mind(victim.controller)
	victim.die()
	victim.reparent($Corpses)


func _unhandled_input(_event: InputEvent) -> void:
	if %Tick.time_left < %Tick.wait_time / 2.0:
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
		if victim is Dancer and victim != shooter:
			if Global.has_controller(victim.controller):
				shooter.kills += 1
			kill(victim)
			break
		p += dir



func check_inputs() -> void:
	for controller in ["wasd", "arrows", "joy0", "joy1", "joy2", "joy3"]:
		if Input.is_action_pressed("up_" + controller):
			Global.plan_direction(controller, Vector2i.UP)
		if Input.is_action_pressed("down_" + controller):
			Global.plan_direction(controller, Vector2i.DOWN)
		if Input.is_action_pressed("left_" + controller):
			Global.plan_direction(controller, Vector2i.LEFT)
		if Input.is_action_pressed("right_" + controller):
			Global.plan_direction(controller, Vector2i.RIGHT)
		if Input.is_action_pressed("shoot_" + controller):
			Global.plan_shoot(controller)
		for i in range(4):
			var joy_vec: Vector2 = Vector2(Input.get_joy_axis(i, JOY_AXIS_LEFT_X), Input.get_joy_axis(i, JOY_AXIS_LEFT_Y))
			if joy_vec.length() > 0.4:
				if abs(joy_vec.x) > abs(joy_vec.y):
					Global.plan_direction("joy"+str(i), Vector2i(sign(joy_vec.x), 0))
				else:
					Global.plan_direction("joy"+str(i), Vector2i(0, sign(joy_vec.y)))
