extends Node2D

@onready var animator : AnimationPlayer = $AnimationPlayer

@onready var jamie_sprite = $Jamie
@onready var jess_sprite = $Jess
@onready var dialogue_ui = $DialogueUI
@onready var dialogue_label = $DialogueUI/Panel/RichTextLabel

@onready var character = GameState.selected_character

@onready var level1: PackedScene = preload("res://Scenes/Levels/Level_01.tscn")

var jamie_dialogue = 'Hello Jessie! Wait, you’re not Jessie? Well, while you’re here, could you do me a favor? I’m trying to make ‘Pepere’s Bread’ but I can’t seem to find all the ‘Ingredients’. If you could bring me the ‘Ingredients’ I can make Pepere’s delicious bread. Oh thank you so much! Come back later and I will give you some of ‘Pepere’s Bread’ while it’s still warm.'

var jess_dialogue = 'Hello Jessie! While you’re here, could you do me a favor? I’m trying to make ‘Pepere’s Bread’ but I can’t seem to find all the ‘Ingredients’. If you could bring me the ‘Ingredients’ I can make Pepere’s delicious bread. Oh thank you so much! Come back later and I will give you some of ‘Pepere’s Bread’ while it’s still warm.'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_music(null)
	#$ColorRect.modulate.a = 0.0
	run_cutscene()


func run_cutscene():
	if character == 0:
		dialogue_label.text = jess_dialogue
		jess_intro()
	else:
		dialogue_label.text = jamie_dialogue
		jamie_intro()

func jess_intro():
	#get_tree().paused = true
	animator.play("mimi_idle")
	
	animator.play("fade_in")
	await animator.animation_finished
	
	animator.play("jess_enter")
	await animator.animation_finished
	
	animator.play("show_dialogue")
	await animator.animation_finished
	
	AudioManager.intro_jess.play()
	await AudioManager.intro_jess.finished
	
	animator.play("hide_dialogue")
	await animator.animation_finished
	
	AudioManager.achievement_sfx.play()
	animator.play("show_obj")
	await animator.animation_finished
	
	await get_tree().create_timer(5.0).timeout
	
	animator.play_backwards("show_obj")
	await animator.animation_finished
	
	jess_sprite.flip_h = true
	animator.play_backwards("jess_enter")
	await animator.animation_finished
	
	animator.play("fade_out")
	await animator.animation_finished
	
	SceneTransition.load_scene(level1)
	
func jamie_intro():
	#get_tree().paused = true
	animator.play("mimi_idle")
	
	animator.play("fade_in")
	await animator.animation_finished
	
	animator.play("jami3_enter")
	await animator.animation_finished
	
	animator.play("show_dialogue")
	await animator.animation_finished
	
	AudioManager.intro_jamie.play()
	await AudioManager.intro_jamie.finished
	
	animator.play("hide_dialogue")
	await animator.animation_finished
	
	AudioManager.achievement_sfx.play()
	animator.play("show_obj")
	await animator.animation_finished
	
	await get_tree().create_timer(5.0).timeout
	
	animator.play_backwards("show_obj")
	await animator.animation_finished
	
	jamie_sprite.flip_h = true
	animator.play_backwards("jami3_enter")
	await animator.animation_finished
	
	animator.play("fade_out")
	await animator.animation_finished
	
	SceneTransition.load_scene(level1)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print(anim_name)
