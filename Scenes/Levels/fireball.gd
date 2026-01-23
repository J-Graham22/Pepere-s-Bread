extends CharacterBody2D

@export var speed : float = 500
@export var gravity : float = 1200
@export var lifetime : float = 2.0

var direction : int = 1

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	velocity.x = speed * direction
	velocity.y += gravity * delta
	move_and_slide()

	if is_on_wall() or is_on_floor():
		queue_free()
