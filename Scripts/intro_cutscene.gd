extends Node2D

@onready var animator : AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$ColorRect.modulate.a = 0.0

	run_cutscene()


func run_cutscene():
	#get_tree().paused = true
	animator.play("mimi_idle")
	
	animator.play("fade_in")
	await animator.animation_finished
	
	animator.play("jami3_enter")
	await animator.animation_finished
	
	print('entered')
	
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print(anim_name)
