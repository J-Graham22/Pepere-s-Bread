extends CharacterBody2D

@export var speed: float = 40
@export var gravity: float = 1400
@export var windup_time: float = 1.0
@export var lunge_cooldown: float = 1.0

enum {
	PATROL,
	ATTACK,
	COOLDOWN
}

var state = PATROL
var direction: int = 1
var is_dead: bool = false
var player_in_range: bool = false

var max_health: int = 10
var current_health

var is_animating : bool = false

@onready var sprite = $Sprite2D
@onready var left_ledge_detector = $RayCastLeft
@onready var right_ledge_detector = $RayCastRight
@onready var windup_timer = Timer.new()
@onready var animation_player = $AnimationPlayer
@onready var flail_hitbox = $FlailHitbox
@onready var detection_area = $DetectionArea

signal health_changed(current, max)
signal skeleton_died

func _ready():
	current_health = max_health
	call_deferred("deferred_health_changed")

func _physics_process(delta: float) -> void:
	if is_dead or is_animating:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		PATROL:
			animation_player.play("Walk")
			patrol()
		COOLDOWN:
			animation_player.play("Idle")
			velocity.x = 0

	move_and_slide()
	check_turnaround()

func patrol():
	velocity.x = direction * speed
		
func start_cooldown():
	state = COOLDOWN
	await get_tree().create_timer(lunge_cooldown).timeout

	state = PATROL
	animation_player.play("Walk")

func check_turnaround():
	if state != PATROL:
		return

	if is_on_wall():
		direction *= -1
		flip_sprite()

func flip_sprite():
	if not sprite:
		return
	sprite.flip_h = direction < 0
	flail_hitbox.scale.x = direction
	detection_area.scale.x = direction

func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_dead:
		return
		
	if body.is_in_group("Player"):
		if state == PATROL:
			attack()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return

	print(body)
	if body.is_in_group("Player"):
		body.take_damage()

	if body.is_in_group("PlayerAttack"):
		take_damage()

func take_damage():
	flash_damage()
	current_health -= 1
	health_changed.emit(current_health, max_health)
	
	if current_health == 0:
		skeleton_died.emit()
		is_dead = true
		AudioManager.enemy_death_sfx.play()
		#play dead animation
		animation_player.play("Die")
		is_animating = true
		

	else:
		animation_player.play("Hit")
		is_animating = true
		
func die():
	await get_tree().create_timer(0.4).timeout
	queue_free()

func attack():
	velocity.x = 0
	animation_player.play("Attack")
	is_animating = true


func _on_flail_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage()
		
func flash_damage():
	modulate = Color(1,0.4,0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"Die":
			is_animating = false
			die()
		"Hit":
			is_animating = false
		"Attack":
			is_animating = false
			start_cooldown()
			
func deferred_health_changed():
	emit_signal("health_changed", current_health, max_health)
