extends Node2D


func _on_tick_timeout() -> void:
	for npc in get_children():
		npc.tick()
