extends CharacterBody2D

@export var patrol_speed: float = 120
@export var patrol_acc: float = 250
@export var dive_speed: float = 200
@export var recovery_speed: float = 160
@export var alignment_margin: float = 20

enum {
	PATROL,
	START_SMASH,
	PLUNGE,
	END_SMASH,
	RECOVER
}

var state = PATROL
var direction = 1
var start_height = 0.0
var player: Node2D
var is_dead: bool = false

@onready var left_bound = $LeftBound.global_position.x
@onready var right_bound = $RightBound.global_position.x
@onready var sprite = $AnimatedSprite2D
@onready var raycast = $RayCast2D

func _ready() -> void:
	start_height = global_position.y

func _physics_process(delta: float) -> void:
	match state:
		PATROL:
			patrol(delta)
		START_SMASH:
			start_smash()
		PLUNGE:
			plunge()
		END_SMASH:
			end_smash()
		RECOVER:
			return_to_patrol(delta)

	move_and_slide()

func patrol(delta: float):
	var target_speed = patrol_speed * direction
	velocity.x = move_toward(velocity.x, target_speed, patrol_acc * delta)
	velocity.y = 0
	
	if global_position.x <= left_bound:
		direction = 1
	if global_position.x >= right_bound:
		direction = -1
		
	flip_sprite()
	sprite.play("Fly")
	check_for_player()
	
func check_for_player():
	if not player:
		return
		
	if abs(player.global_position.x - global_position.x) <= alignment_margin:
		velocity = Vector2.ZERO
		state = START_SMASH

		
func start_smash():
		sprite.play("StartSmash")
		await sprite.animation_finished
		state = PLUNGE
	
func plunge():
	velocity.x = 0
	velocity.y = dive_speed
	sprite.play("Smashing")
	if is_on_floor() or raycast.is_colliding():
		velocity = Vector2.ZERO
		state = END_SMASH
		
func end_smash():
	sprite.play("SmashEnd")
	await sprite.animation_finished
	state = RECOVER

func return_to_patrol(delta: float):
	sprite.play("Idle")
	velocity.x = 0
	velocity.y = move_toward(velocity.y, -recovery_speed, recovery_speed * delta)
	
	if global_position.y <= start_height:
		global_position.y = start_height
		velocity = Vector2.ZERO
		state = PATROL

func flip_sprite():
	if not sprite:
		return
	sprite.flip_h = direction > 0


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
	queue_free()
