extends Node2D

@onready var animator : AnimationPlayer = $AnimationPlayer

@onready var mimi_sprite = $Mimi
@onready var jamie_sprite = $Jamie
@onready var jess_sprite = $Jess
@onready var dialogue_ui = $DialogueUI
@onready var dialogue_label = $DialogueUI/Panel/RichTextLabel
@onready var objective_label = $ObjectiveUI/Panel/ObjectiveLabel
@onready var mixing_bowl = $"Mixing Bowl"
@onready var bread = $Bread

@onready var character = GameState.selected_character

var ingredients_ready_dialogue = 'I have the ingredients Mimi!'
var thanks_dialogue = 'Oh thank you so much!'
var handing_ingredients_diaglogue = 'You hand Mimi the ‘Ingredients’'
var create_bread_success_dialogue = 'You’ve made ‘Pepere’s Bread’!'

var completion_text_jess = '‘Pepere’s Bread’ is nice and warm. Thanks again Jess! Stop by anytime dear.'
var completion_text_jamie = '‘Pepere’s Bread’ is nice and warm. Thank you so much! Stop by anytime dear.'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run_cutscene()

func run_cutscene():
	#get_tree().paused = true
	animator.play("mimi_idle")
	
	animator.play("fade_in")
	await animator.animation_finished
	
	dialogue_label.text = ingredients_ready_dialogue
	animator.play("show_dialogue")
	await animator.animation_finished
	await get_tree().create_timer(2.0).timeout
	animator.play_backwards("show_dialogue")
	await animator.animation_finished
	
	mimi_sprite.flip_h = !mimi_sprite.flip_h
	
	if character == 0:
		animator.play("jess_enter")
		await animator.animation_finished
	else:
		animator.play("jami3_enter")
		await animator.animation_finished
	
	dialogue_label.text = thanks_dialogue
	animator.play("show_dialogue")
	await animator.animation_finished
	
	AudioManager.completion_thanks.play()
	await AudioManager.completion_thanks.finished
	
	animator.play_backwards("show_dialogue")
	await animator.animation_finished
	
	#dialogue showing handing ingredients
	objective_label.text = handing_ingredients_diaglogue
	animator.play("show_obj")
	await animator.animation_finished
	await get_tree().create_timer(2.0).timeout
	animator.play_backwards("show_obj")
	await animator.animation_finished
	
	#mimi walks back to bowl
	mimi_sprite.flip_h = !mimi_sprite.flip_h
	animator.play("mimi_walk_to_bowl")
	await animator.animation_finished
	
	#mimi starts making the bread
	mimi_sprite.frame = 0
	# add in cooking sounds here
	AudioManager.kitchen_sounds.play()
	await get_tree().create_timer(6.0).timeout
	AudioManager.kitchen_sounds.playing = false
	
	#you made pepere's bread
	objective_label.text = create_bread_success_dialogue
	animator.play("show_obj")
	await animator.animation_finished
	await get_tree().create_timer(2.0).timeout
	animator.play_backwards("show_obj")
	await animator.animation_finished
	
	#bread on counter
	mixing_bowl.visible = false
	bread.visible = true
	
	#mimi goes back to initial position
	mimi_sprite.flip_h = !mimi_sprite.flip_h
	animator.play_backwards("mimi_walk_to_bowl")
	await animator.animation_finished
	
	#says closing dialouge
	if character == 0:
		dialogue_label.text = completion_text_jess
	else:
		dialogue_label.text = completion_text_jamie
	animator.play("show_dialogue")
	await animator.animation_finished
	
	if character == 0:
		AudioManager.completion_jess.play()
		await AudioManager.completion_jess.finished
	else:
		AudioManager.completion_jamie.play()
		await AudioManager.completion_jamie.finished
	
	animator.play_backwards("show_dialogue")
	await animator.animation_finished
	
	animator.play_backwards("fade_in")
	await animator.animation_finished
	
	#######################################
	
