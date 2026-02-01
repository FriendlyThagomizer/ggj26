extends Node2D

var wait: float = Global.tick_duration / 2
var up: float = Global.tick_duration / 4
var down: float = Global.tick_duration / 4
var all_time: float = 0.0

func _process(delta: float) -> void:
	all_time += delta
	if all_time < wait:
		return
	var time: float = all_time - wait
	$Sprite.visible = true
	if time < up:
		$Sprite.modulate.a = time / up / 2.0
	elif time < up + down:
		$Sprite.modulate.a = (1 - ((time - up) / down))/2.0
	else:
		queue_free()
