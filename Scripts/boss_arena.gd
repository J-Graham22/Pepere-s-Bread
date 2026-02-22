extends Node2D

@export var arena_left : float = 15870
@export var arena_right : float = 18530
@export var arena_top : float = 250
@export var arena_bottom : float = 2500

@onready var exit_blocker : StaticBody2D = $ExitBlocker
@onready var skeleton_health_ui : Control = %SkeletonHealth
@onready var skeleton_health_bar : TextureProgressBar = %SkeletonHealth/TextureProgressBar
#@onready var skeleton_health_bar : ProgressBar = %SkeletonHealth/ProgressBar



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	exit_blocker.set_deferred("disabled", true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_arena_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		start_boss_fight()
		
func start_boss_fight():
	var cam = %Camera2D

	cam.limit_left = arena_left
	cam.limit_right = arena_right
	cam.limit_top = arena_top
	cam.limit_bottom = arena_bottom
	
	exit_blocker.set_deferred("disabled", false)
	
func end_boss_fight():
	var cam = %Camera2D

	cam.limit_left = -100000
	cam.limit_right = 100000
	cam.limit_top = -100000
	cam.limit_bottom = 100000
	
	exit_blocker.set_deferred("disabled", true)


func _on_skeleton_boss_health_changed(current: Variant, max: Variant) -> void:
	skeleton_health_bar.max_value = max
	skeleton_health_bar.value = current


func _on_skeleton_boss_skeleton_died() -> void:
	end_boss_fight()


func _on_player_player_died() -> void:
	end_boss_fight()
