extends CharacterBody2D

@export var speed: float = 40
var patrol_speed : float = speed
@export var chase_speed: float = 100
@export var gravity: float = 1400

var player: Node = null
var direction: int = 1

@onready var sprite = $AnimatedSprite2D
@onready var left_ledge_detector = $RayCastLeft
@onready var right_ledge_detector = $RayCastRight

enum {
	PATROL,
	CHASE,
	DEAD,
	REVIVING
}

var state = PATROL


func _physics_process(delta: float) -> void:
	if state == DEAD or state == REVIVING:
		return

		
	if player:
		follow_player()
	else:
		patrol()

	move_and_slide()
	handle_animations()
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
	sprite.flip_h = direction < 0
	
func follow_player():
	if player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1

	velocity.x = direction * chase_speed
	flip_sprite()
	
func patrol():
	var rand = RandomNumberGenerator.new()
	rand.randomize()
		
	# if moving, 1% chance to stop and vice versa every frame
	if randi() % 100 == 0:
		if abs(velocity.x) > 0:
			patrol_speed = 0
		else:
			patrol_speed = speed
	
	#0.1% chance to change direction every frame
	if randi() % 1000 == 0:
		direction *= -1
		flip_sprite()
		
	#print(patrol_speed)
	velocity.x = direction * patrol_speed

func handle_animations():
	if state == DEAD or state == REVIVING:
		return

	if abs(velocity.x) > 0:
		if player:
			sprite.play("Run")
		else:
			sprite.play("Walk")
	else:
		sprite.play("Idle")

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body

func _on_hitbox_body_entered(body: Node2D) -> void:
	#print('goblin collision')
	#print(body.get_groups())
	if state == DEAD or state == REVIVING:
		return

		
	if body.is_in_group("Player"):
		body.take_damage()
		
	if body.is_in_group("PlayerAttack"):
		take_damage()
	
func take_damage():
	if state == DEAD or state == REVIVING:
		return

	state = DEAD
	velocity = Vector2.ZERO
	sprite.play("Die")
	
	await sprite.animation_finished
	
	sprite.stop()
	sprite.frame = sprite.sprite_frames.get_frame_count("Die") - 1
	#implement the death and rebirth here
	await get_tree().create_timer(3.0).timeout
	revive()
	
func revive():
	state = REVIVING
	sprite.play_backwards("Die")
	
	await sprite.animation_finished
	
	state = PATROL
	player = null
	sprite.play("Idle")
