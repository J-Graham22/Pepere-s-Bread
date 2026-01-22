extends CharacterBody2D

# --------- VARIABLES ---------- #

@export_category("Player Properties")

@export var max_speed : float = 400
@export var acceleration : float = 1300
@export var max_run_speed: float = 800
@export var run_acceleration: float = 2000

@export var friction : float = 1300
@export var air_control : float = 0.7

@export var jump_force : float = 800
@export var gravity : float = 1600
@export var fall_gravity : float = 2200
@export var jump_cut_multiplier : float = 0.4

@export var coyote_time : float = 0.1

var coyote_timer : float = 0.0

@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles

# --------- BUILT-IN FUNCTIONS ---------- #

func _physics_process(delta):
	apply_gravity(delta)
	handle_horizontal_movement(delta)
	handle_jumping()
	move_and_slide()

	player_animations()
	flip_player()

# --------- MOVEMENT ---------- #

func apply_gravity(delta):
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

		if velocity.y < 0:
			velocity.y += gravity * delta
		else:
			velocity.y += fall_gravity * delta

func handle_horizontal_movement(delta):
	var input_axis = Input.get_axis("Left", "Right")

	if input_axis != 0:
		var accel = run_acceleration if Input.is_action_pressed("Run") else acceleration
		var max_sp = max_run_speed if Input.is_action_pressed("Run") else max_speed
		
		if !is_on_floor():
			accel *= air_control

		velocity.x = move_toward(
			velocity.x,
			input_axis * max_sp,
			accel * delta
		)
			
	else:
		if is_on_floor():
			velocity.x = move_toward(
				velocity.x,
				0,
				friction * delta
			)

func handle_jumping():
	if Input.is_action_just_pressed("Jump") and coyote_timer > 0:
		jump()

	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

func jump():
	coyote_timer = 0
	jump_tween()
	AudioManager.jump_sfx.play()
	velocity.y = -jump_force

# --------- ANIMATIONS ---------- #

func player_animations():
	particle_trails.emitting = false

	if is_on_floor():
		if abs(velocity.x) > 20:
			particle_trails.emitting = true
			player_sprite.play("Walk", 1.5)
		else:
			player_sprite.play("Idle")
	else:
		player_sprite.play("Jump")

func flip_player():
	if velocity.x < 0:
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false

# --------- TWEENS ---------- #

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func death_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	global_position = spawn_point.global_position
	await get_tree().create_timer(0.3).timeout
	AudioManager.respawn_sfx.play()
	respawn_tween()

func respawn_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15)

# --------- SIGNALS ---------- #

func _on_collision_body_entered(body):
	if body.is_in_group("Traps"):
		AudioManager.death_sfx.play()
		death_particles.emitting = true
		death_tween()
