extends CharacterBody2D

# --------- VARIABLES ---------- #
@export_category("Character")
enum Character {
	JESS,
	JAMIE
}
@export var character_toggle: Character = Character.JESS

var jess_frames = preload("res://Assets/Spritesheet/Jess/jess_sprite_frames.tres")
var jamie_frames = preload("res://Assets/Spritesheet/Jamie/jamie_sprite_frames.tres")

@export_category("Fireball")

@export var can_shoot_fireball : bool = true
@export var fireball_scene : PackedScene
@export var max_fireballs : int = 2
@export var fire_cooldown : float = 0.25

var fire_timer : float = 0.0
var swing_timer: float = 0.0

@export_category("Magic Sword")

@export var can_swing_sword : bool = true
@export var slash_scene: PackedScene
@export var swing_cooldown : float = 0.25

@export_category("Player Properties")

@export var max_health: int = 3

@export var max_speed : float = 400
@export var acceleration : float = 1300
@export var max_run_speed: float = 800
@export var run_acceleration: float = 2000
@export var i_frames : float = 1.0

@export var friction : float = 1300
@export var air_control : float = 0.7

@export var jump_force : float = 800
@export var gravity : float = 1600
@export var fall_gravity : float = 2200
@export var jump_cut_multiplier : float = 0.4

@export var coyote_time : float = 0.1

var coyote_timer : float = 0.0

var current_health: int

var in_water: bool = false

var invincible: bool = false

var checkpoint_pos: Vector2 = Vector2.INF

@export var water_gravity: float = 400
@export var water_max_speed : float = 120
@export var swim_jump_force : float = 250
@export var water_drag : float = 600


@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles

# --------- BUILT-IN FUNCTIONS ---------- #
func _ready() -> void:
	current_health =  max_health
	if GameState.selected_character == GameState.Character.JESS:
		character_toggle = Character.JESS
	else:
		character_toggle = Character.JAMIE
	
	apply_character()
	call_deferred("deferred_health_changed")
	
func apply_character():
	match character_toggle:
		Character.JESS:
			player_sprite.sprite_frames = jess_frames
			return
		Character.JAMIE:
			player_sprite.sprite_frames = jamie_frames
			return
			
func is_jess():
	return character_toggle == Character.JESS

func _physics_process(delta):
	fire_timer -= delta
	swing_timer -= delta
	
	#if in_water:
		#velocity = velocity.move_toward(Vector2.ZERO, water_drag * delta)

	apply_gravity(delta)
	handle_horizontal_movement(delta)
	handle_jumping()
	if character_toggle == Character.JESS:
		handle_fireball()
	if character_toggle == Character.JAMIE:
		handle_swing()
	
	move_and_slide()

	player_animations()
	flip_player()

# --------- MOVEMENT ---------- #

func apply_gravity(delta):
	if in_water:
		velocity.y += water_gravity * delta
	else:
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
		
		if in_water:
			max_sp = water_max_speed
			accel *= 0.5
		
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
	if in_water:
		if Input.is_action_just_pressed("Jump"):
			velocity.y = -swim_jump_force
		return
	
	if Input.is_action_just_pressed("Jump") and coyote_timer > 0:
		jump()

	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier
		
func handle_fireball():
	if !can_shoot_fireball:
		return

	if Input.is_action_just_pressed("Run") and fire_timer <= 0:
		if get_tree().get_nodes_in_group("Fireballs").size() < max_fireballs:
			shoot_fireball()
			fire_timer = fire_cooldown
			
func shoot_fireball():
	var fireball = fireball_scene.instantiate()
	fireball.global_position = global_position + Vector2(24 * get_facing_direction(), -8)
	fireball.direction = get_facing_direction()
	fireball.add_to_group("Fireballs")
	get_tree().current_scene.add_child(fireball)

	# AudioManager.fireball_sfx.play()
	
func handle_swing():
	if !can_swing_sword:
		return

	if Input.is_action_just_pressed("Run") and swing_timer <= 0:
		swing()
		swing_timer = swing_cooldown
			
func swing():
	player_sprite.play("Attack")
	var slash = slash_scene.instantiate()
	slash.global_position = global_position + Vector2(24 * get_facing_direction(), -8)
	slash.direction = get_facing_direction()
	get_tree().current_scene.add_child(slash)

func jump():
	coyote_timer = 0
	jump_tween()
	AudioManager.jump_sfx.play()
	velocity.y = -jump_force
	
func take_damage():
	#todo: implement animation for taking damage
	if invincible:
		return
		
	invincible = true
	current_health -= 1
	emit_signal("health_changed", current_health, max_health)
	
	flash_damage()
	
	if current_health == 0:
		die()
		# and then respawn
		current_health = max_health
		
	await get_tree().create_timer(i_frames).timeout
	invincible = false
	emit_signal("health_changed", current_health, max_health)
	
func is_at_max_health():
	return current_health == max_health
	
func heal():
	if is_at_max_health():
		return
	current_health += 1
	emit_signal("health_changed", current_health, max_health)

# --------- ANIMATIONS ---------- #
func flash_damage():
	modulate = Color(1,0.4,0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE

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
		
func get_facing_direction() -> int:
	return -1 if player_sprite.flip_h else 1
	
func die():
	player_died.emit()
	AudioManager.death_sfx.play()
	death_particles.emitting = true
	death_tween()
	
func set_checkpoint(pos: Vector2):
	checkpoint_pos = pos
	
func get_spawn_point():
	if checkpoint_pos != Vector2.INF:
		return checkpoint_pos
	else:
		return spawn_point.global_position

# --------- TWEENS ---------- #

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func death_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	global_position = get_spawn_point()
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.3).timeout
	AudioManager.respawn_sfx.play()
	respawn_tween()

func respawn_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15)
	
# --------- EXTERNAL SIGNALS ---------- #
signal health_changed(current, max)
signal player_died

func deferred_health_changed():
	emit_signal("health_changed", current_health, max_health)

# --------- SIGNALS ---------- #

func _on_collision_body_entered(body):
	if body.is_in_group("Traps"):
		die()


func _on_water_body_entered(body: Node2D) -> void:
	if body == self:
		in_water = true
		
		if abs(body.velocity.x) > water_max_speed:
			if body.velocity.x > 0:
				body.velocity.x = water_max_speed
			else:
				body.velocity.x = -water_max_speed
		if abs(body.velocity.y) > water_max_speed:
			if body.velocity.y > 0:
				body.velocity.y = water_max_speed
			else:
				body.velocity.y = -water_max_speed


func _on_water_body_exited(body: Node2D) -> void:
	if body == self:
		in_water = false
		body.velocity.y = -700
