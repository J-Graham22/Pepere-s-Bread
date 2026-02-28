extends Node2D

@onready var main_menu : PackedScene = preload("res://Scenes/Levels/TitleScreen.tscn")

@onready var animator : AnimationPlayer = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_music(null)
	roll_credits()


func roll_credits():
	AudioManager.credits.play()
	animator.play("credits_scroll")
	await animator.animation_finished
	
	SceneTransition.load_scene(main_menu)
