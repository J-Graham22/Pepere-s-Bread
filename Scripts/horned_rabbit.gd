extends CharacterBody2D

@export var speed: float = 40
@export var lunge_speed: float = 380
@export var jump_force: float = 400
@export var gravity: float = 1400
@export var windup_time: float = 1.0
@export var lunge_cooldown: float = 1.0

enum {
	PATROL,
	WINDUP,
	LUNGING,
	COOLDOWN
}

var state = PATROL
var player: Node2D = null
var direction: int = -1
var is_dead: bool = false
var has_left_floor: bool = false
var player_in_range: bool = false

@onready var sprite = $AnimatedSprite2D
@onready var left_ledge_detector = $RayCastLeft
@onready var right_ledge_detector = $RayCastRight
@onready var windup_timer = Timer.new()

func _ready():
	windup_timer.one_shot = true
	windup_timer.wait_time = windup_time
	windup_timer.timeout.connect(_on_windup_finished)
	add_child(windup_timer)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		PATROL:
			sprite.play("Walking")
			patrol()
		WINDUP:
			sprite.play("Idle")
			velocity.x = 0
		LUNGING:
			sprite.play("Attack")
			handle_lunge_landing()
		COOLDOWN:
			sprite.play("Idle")
			velocity.x = 0

	move_and_slide()
	check_turnaround()

func patrol():
	velocity.x = direction * speed

func start_windup():
	if not player_in_range:
		return
	state = WINDUP
	sprite.play("Idle")
	windup_timer.start()

func _on_windup_finished():
	if not player:
		state = PATROL
		sprite.play("Walking")
		return

	state = LUNGING
	sprite.play("Attack")
	has_left_floor = false

	var lunge_dir = (player.global_position - global_position).normalized()
	velocity.x = lunge_dir.x * lunge_speed
	velocity.y = -jump_force
	check_turnaround()
	#await get_tree().create_timer(lunge_cooldown).timeout
	
func handle_lunge_landing():
	if not is_on_floor():
		has_left_floor = true
		
	if is_on_floor() and has_left_floor:
		has_left_floor = false
		start_cooldown()
		sprite.play("Idle")
		
func start_cooldown():
	state = COOLDOWN
	await get_tree().create_timer(lunge_cooldown).timeout

	if player_in_range:
		start_windup()
	else:
		state = PATROL
		sprite.play("Walking")

func check_turnaround():
	if state != PATROL:
		return

	if is_on_wall():
		direction *= -1
		flip_sprite()

	if direction == -1 and !left_ledge_detector.is_colliding():
		direction *= -1
		flip_sprite()
	elif direction == 1 and !right_ledge_detector.is_colliding():
		direction *= -1
		flip_sprite()

func flip_sprite():
	sprite.flip_h = direction > 0

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_in_range = true
		if state == PATROL:
			start_windup()

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


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
		player_in_range = false
