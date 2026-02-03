extends CharacterBody2D

@export var speed: float = 40
var patrol_speed : float = speed
@export var chase_speed: float = 100
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


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body

func _on_hitbox_body_entered(body: Node2D) -> void:
	print('goblin collision')
	print(body.get_groups())
	if is_dead:
		return
		
	if body.is_in_group("Player"):
		body.take_damage()
		
	if body.is_in_group("PlayerAttack"):
		take_damage()
	
func take_damage():
	is_dead = true
	
	#implement the death and rebirth here
	self.visible = false
	await get_tree().create_timer(5.0).timeout
	self.visible = true
	#queue_free() # Replace with function body.
	is_dead = false
	player = null
