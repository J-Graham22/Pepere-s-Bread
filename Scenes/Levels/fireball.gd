extends CharacterBody2D

@export var speed : float = 500
@export var gravity : float = 1200
@export var bounce_force: float = 450
@export var max_bounces: int = 2
@export var lifetime : float = 4.0

var direction : int = 1
var bounce_count: int = 0

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	velocity.x = speed * direction
	velocity.y += gravity * delta
	
	move_and_slide()
	
	handle_collisions()
		
func handle_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()

		# Hit a wall → die
		if abs(normal.x) > 0.7:
			queue_free()
			return

		# Hit ceiling → die
		if normal.y > 0.7:
			queue_free()
			return

		# Hit floor → bounce
		if normal.y == -1.0:
			bounce()
			break

func bounce():
	if bounce_count >= max_bounces:
		queue_free()
		return

	bounce_count += 1
	velocity.y = -bounce_force
