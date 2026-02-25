extends Node2D

@onready var animator : AnimationPlayer = $AnimationPlayer

@onready var jamie_sprite = $Jamie
@onready var jess_sprite = $Jess

@onready var character = GameState.selected_character

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$ColorRect.modulate.a = 0.0
	run_cutscene()


func run_cutscene():
	if character == 0:
		jess_intro()
	else:
		jamie_intro()

func jess_intro():
	#get_tree().paused = true
	animator.play("mimi_idle")
	
	animator.play("fade_in")
	await animator.animation_finished
	
	animator.play("jess_enter")
	await animator.animation_finished
	
	AudioManager.intro_jess.play()
	await AudioManager.intro_jess.finished
	
	jess_sprite.flip_h = true
	animator.play_backwards("jess_enter")
	await animator.animation_finished
	
	animator.play("fade_out")
	await animator.animation_finished
	
func jamie_intro():
	#get_tree().paused = true
	animator.play("mimi_idle")
	
	animator.play("fade_in")
	await animator.animation_finished
	
	animator.play("jami3_enter")
	await animator.animation_finished
	
	AudioManager.intro_jamie.play()
	await AudioManager.intro_jamie.finished
	
	jamie_sprite.flip_h = true
	animator.play_backwards("jami3_enter")
	await animator.animation_finished
	
	animator.play("fade_out")
	await animator.animation_finished

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print(anim_name)
