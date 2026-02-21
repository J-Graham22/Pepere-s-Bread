extends CharacterBody2D

@export var speed : float = 500
@export var lifetime : float = 1.0

var direction : int = 1

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	velocity.x = speed * direction
	velocity.y = 0
	
	move_and_slide()
