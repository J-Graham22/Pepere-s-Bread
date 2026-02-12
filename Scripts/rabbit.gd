extends CharacterBody2D

@export var speed: float = 60
@export var gravity: float = 1400

var direction: int = -1
var is_dead: bool = false

@onready var sprite = $AnimatedSprite2D
#@onready var sprite = $Sprite2D
@onready var left_ledge_detector = $RayCastLeft
@onready var right_ledge_detector = $RayCastRight
@onready var death_particles = $DeathParticles

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	velocity.y += gravity * delta
	velocity.x = direction * speed
	
	if abs(velocity.x) > 0:
		sprite.play("Moving")

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

func _on_area_body_entered(body: Node2D) -> void:
	if is_dead:
		return
		
	if body.is_in_group("Player"):
		body.take_damage()
		
	if body.is_in_group("PlayerAttack"):
		take_damage()
	
func take_damage():
	is_dead = true
	
	await get_tree().create_timer(0.4).timeout
	die()
	queue_free()
	
func die():
	AudioManager.death_sfx.play()
	death_particles.emitting = true
	death_tween()
	
func death_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
