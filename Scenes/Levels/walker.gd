extends CharacterBody2D

@export var speed: float = 60
@export var gravity: float = 1400

var direction: int = -1
var is_dead: bool = false

#@onready var sprite = $AnimatedSprite2D
@onready var sprite = $Sprite2D
@onready var left_ledge_detector = $RayCastLeft
@onready var right_ledge_detector = $RayCastRight

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	velocity.y += gravity * delta
	velocity.x = direction * speed

	move_and_slide()
	
	check_turnaround()
	
func check_turnaround():
	# Hit a wall
	if is_on_wall():
		print('hit a wall')
		direction *= -1
		flip_sprite()

	# About to fall off ledge
	if direction == -1:
		if !left_ledge_detector.is_colliding():
			print('boutta fall off dis ledge')
			direction *= -1
			flip_sprite()
	else:
		if !right_ledge_detector.is_colliding():
			print('boutta fall off dis ledge')
			direction *= -1
			flip_sprite()
		

func flip_sprite():
	sprite.flip_h = direction > 0


func _on_stompbox_body_entered(body: Node2D) -> void:
	print(body)
	if body.is_in_group("Player") and body.velocity.y > 0:
		stomped(body)

func stomped(player):
	if is_dead:
		return

	is_dead = true
	#sprite.play("Flat")  # squish animation

	# Bounce the player up
	player.velocity.y = -300

	await get_tree().create_timer(0.4).timeout
	queue_free()
