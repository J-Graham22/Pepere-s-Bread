extends CharacterBody2D

@export var speed: float = 40
@export var gravity_in_air: float = 1200
@export var flop_speed: float = 300

enum {
	PATROL,
	PLAYER_SPOTTED,
}

var state = PATROL
var player: Node2D = null
var direction: int = -1
var is_dead: bool = false
var player_in_range: bool = false
var in_water: bool = true

@onready var sprite = $Sprite2D

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if in_water:
		if player_in_range:
			state = PLAYER_SPOTTED
		else:
			state = PATROL

		match state:
			PATROL:
				patrol()
			PLAYER_SPOTTED:
				player_spotted()
	else:
		out_of_water(delta)

	move_and_slide()
	check_turnaround()

func patrol():
	velocity.x = direction * speed
	
func player_spotted():
	var player_dir = (player.global_position - global_position).normalized()
	velocity.x = player_dir.x * speed
	velocity.y = player_dir.y * speed
	
func out_of_water(delta: float):
	velocity.y += gravity_in_air * delta
	
	if is_on_floor():
		velocity.y = -flop_speed

func check_turnaround():
	if state != PATROL:
		return

	if is_on_wall():
		direction *= -1
		flip_sprite()

func flip_sprite():
	sprite.flip_h = direction > 0

func take_damage():
	is_dead = true
	
	await get_tree().create_timer(0.4).timeout
	queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_in_range = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
		player_in_range = false


func _on_hitbox_2d_body_entered(body: Node2D) -> void:
	print('fish collision')
	print(body.get_groups())
	if is_dead:
		return

	if body.is_in_group("Player") and in_water:
		body.take_damage()

	if body.is_in_group("PlayerAttack"):
		take_damage()

func _on_hitbox_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Water"):
		in_water = true

func _on_hitbox_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Water"):
		in_water = false
