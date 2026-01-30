extends CharacterBody2D

@export var speed: float = 200

func _physics_process(_delta: float) -> void:
	var d: Vector2 = Input.get_vector("west", "east", "north", "south")
	velocity = d * speed
	move_and_slide()
	
	var should_play_animation: bool = d != Vector2.ZERO
	if $Animation.is_playing() && !should_play_animation:
		$Animation.pause()
	elif !$Animation.is_playing() && should_play_animation:
		$Animation.play()
	if d.x < 0:
		$Animation.flip_h = true
	elif d.x > 0:
		$Animation.flip_h = false

func _draw() -> void:
	draw_circle(Vector2.ZERO, 20, Color.GREEN)


func _on_trap_check_area_entered(area: Area2D) -> void:
	position = $"../Start".position
