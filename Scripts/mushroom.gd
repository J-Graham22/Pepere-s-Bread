extends CharacterBody2D

@export var speed: float = 40
@export var lunge_speed: float = 380
@export var jump_force: float = 400
@export var gravity: float = 1400
@export var windup_time: float = 1.0
@export var lunge_cooldown: float = 1.0
@export var stun_time: float = 0.6
@export var knockback_pwr:float = 100

enum {
	PATROL,
	WINDUP,
	LUNGING,
	COOLDOWN,
	STUNNED
}

var max_health: int = 3
var current_health

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
@onready var stun_timer = Timer.new()

func _ready():
	current_health = max_health
	
	windup_timer.one_shot = true
	windup_timer.wait_time = windup_time
	windup_timer.timeout.connect(_on_windup_finished)
	add_child(windup_timer)
	
	stun_timer.one_shot = true
	stun_timer.wait_time = stun_time
	stun_timer.timeout.connect(_on_stun_finished)
	add_child(stun_timer)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		PATROL:
			patrol()
		WINDUP:
			velocity.x = 0
		LUNGING:
			handle_lunge_landing()
		COOLDOWN:
			velocity.x = 0
		STUNNED:
			velocity.x = move_toward(velocity.x, 0, 1000 * delta)

	move_and_slide()
	check_turnaround()

func patrol():
	velocity.x = direction * speed

func start_windup():
	if not player_in_range:
		return
	state = WINDUP
	windup_timer.start()

func _on_windup_finished():
	if not player:
		state = PATROL
		return

	state = LUNGING
	has_left_floor = false

	var lunge_dir = (player.global_position - global_position).normalized()
	velocity.x = lunge_dir.x * lunge_speed
	velocity.y = -jump_force
	flip_sprite()
	#await get_tree().create_timer(lunge_cooldown).timeout
	
func _on_stun_finished():
	if is_dead:
		return
		
	if player_in_range:
		start_windup()
	else:
		state = PATROL

	
func handle_lunge_landing():
	if not is_on_floor():
		has_left_floor = true
		
	if is_on_floor() and has_left_floor:
		has_left_floor = false
		start_cooldown()
		
func start_cooldown():
	state = COOLDOWN
	await get_tree().create_timer(lunge_cooldown).timeout

	if player_in_range:
		start_windup()
	else:
		state = PATROL

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
	current_health -= 1
	
	if current_health == 0:
		is_dead = true
		
		await get_tree().create_timer(0.4).timeout
		queue_free()
	else:
		stun()
		# stun logic here

func stun():
	state = STUNNED
	
	# Stop windup if active
	if windup_timer.time_left > 0:
		windup_timer.stop()
	
	# Knockback away from player if exists
	if player:
		var dir = sign(global_position.x - player.global_position.x)
		velocity.x = dir * knockback_pwr
		velocity.y = -100
	
	stun_timer.start()


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
		player_in_range = false
