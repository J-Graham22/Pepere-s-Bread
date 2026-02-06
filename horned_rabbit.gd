extends CharacterBody2D

@export var speed: float = 40
@export var lunge_speed: float = 100
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
		lunge()
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
	
func lunge():
	if not is_on_floor():
		return
		
	var direction_of_lunge: Vector2 = player.position - self.position

	velocity.x = direction_of_lunge.x * lunge_speed
	velocity.y = direction_of_lunge.y * lunge_speed
	
func patrol():
	velocity.x = direction * speed


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body

func _on_hitbox_body_entered(body: Node2D) -> void:
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
