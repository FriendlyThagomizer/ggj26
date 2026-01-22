extends CharacterBody2D

@export var speed: float = 100

func _physics_process(_delta: float) -> void:
	var d: Vector2 = Input.get_vector("west", "east", "north", "south")
	velocity = d * speed
	move_and_slide()
