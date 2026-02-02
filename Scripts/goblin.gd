extends CharacterBody2D

@export var speed: float = 60
@export var chase_speed: float = 90
@export var gravity: float = 1400

var player: Node = null
var direction: int = -1
var is_dead: bool = false

#@onready var sprite = $AnimatedSprite2D
@onready var sprite = $Sprite2D
@onready var left_ledge_detector = $RayCastLeft
@onready var right_ledge_detector = $RayCastRight

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if player:
		follow_player()
	else:
		patrol()

	move_and_slide()
	check_turnaround()
	
func check_turnaround():
	# Hit a wall
	if is_on_wall():
		direction *= -1
		flip_sprite()

	# About to fall off ledge
	if direction == -1:
		if !left_ledge_detector.is_colliding():
			direction *= -1
			flip_sprite()
	else:
		if !right_ledge_detector.is_colliding():
			direction *= -1
			flip_sprite()
			
func flip_sprite():
	sprite.flip_h = direction > 0
	
func follow_player():
	if player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1

	velocity.x = direction * chase_speed
	flip_sprite()
	
func patrol():
	velocity.x = direction * speed


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null


func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
		
	if body.is_in_group("Player"):
		body.take_damage()
		
	if body.is_in_group("PlayerAttack"):
		take_damage()
	
func take_damage():
	is_dead = true
	
	await get_tree().create_timer(0.4).timeout
	queue_free() # Replace with function body.
