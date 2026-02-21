extends CharacterBody2D

@export var speed: float = 40
@export var gravity_in_air: float = 1200
@export var flop_speed: float = 300

var player: Node2D = null
var direction: int = -1
var is_dead: bool = false
var in_water: bool = true

@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox2D
@onready var water = %Water

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if in_water:
		patrol()
	else:
		out_of_water(delta)

	move_and_slide()
	check_turnaround()
	
func set_in_water(val: bool):
	in_water = val

func patrol():
	velocity.x = direction * speed
	
func out_of_water(delta: float):
	velocity.x = 0
	velocity.y += gravity_in_air * delta
	
	if is_on_floor():
		velocity.y = -flop_speed

func check_turnaround():
	if is_on_wall():
		direction *= -1
		flip_sprite()

func flip_sprite():
	if not sprite:
		return
	sprite.flip_h = direction > 0

func take_damage():
	flash_damage()
	is_dead = true
	
	await get_tree().create_timer(0.4).timeout
	queue_free()


func _on_hitbox_2d_body_entered(body: Node2D) -> void:
	if is_dead:
		return

	if body.is_in_group("Player") and in_water:
		body.take_damage()

	if body.is_in_group("PlayerAttack"):
		take_damage()
		
func flash_damage():
	modulate = Color(1,0.4,0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
