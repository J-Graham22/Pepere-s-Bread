extends Node2D

@onready var animator : AnimationPlayer = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	roll_credits()


func roll_credits():
	animator.play("credits_scroll")
	await animator.animation_finished
	
	animator.play("show_memorial")
	await animator.animation_finished
	
	animator.play_backwards("show_memorial")
	await animator.animation_finished
