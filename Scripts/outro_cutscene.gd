extends Node2D

@onready var animator = $AnimationPlayer

@onready var dialogue_label = $DialogueUI/Panel/RichTextLabel

var outro_jess = 'I love you Jess, from here to the moon, always!'
var outro_jamie = 'I love you, from here to the moon, always!'

@onready var character = GameState.selected_character

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run_cutscene()

func run_cutscene():
	animator.play("fade_in")
	await animator.animation_finished
	
	animator.play("mimi_stairs_first_half")
	await animator.animation_finished
	
	if character == 0:
		dialogue_label.text = outro_jess
	else:
		dialogue_label.text = outro_jamie
	animator.play("show_dialogue")
	await animator.animation_finished
	
	if character == 0:
		AudioManager.outro_jess.play()
		await AudioManager.outro_jess.finished
	else:
		AudioManager.outro_jamie.play()
		await AudioManager.outro_jamie.finished
	
	animator.play_backwards("show_dialogue")
	await animator.animation_finished
	
	animator.play("mimi_stairs_second_half")
	await animator.animation_finished
