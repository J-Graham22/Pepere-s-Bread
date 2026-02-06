extends Area2D

# Define the next scene to load in the inspector
@export var next_scene : PackedScene

var ingredient_0_collected : bool = false
var ingredient_1_collected : bool = false

# Load next level scene when player collide with level finish door.
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if not ingredient_0_collected or not ingredient_1_collected:
			print('missing ingredients!')
			return
		# need to check that player has retrieved the necessary ingredients
		#and Input.is_action_pressed("Confirm"):
		get_tree().call_group("Player", "death_tween") # death_tween is called here just to give the feeling of player entering the door.
		AudioManager.level_complete_sfx.play()
		SceneTransition.load_scene(next_scene)


func _on_ingredient_collected() -> void:
	ingredient_0_collected = true


func _on_ingredient_2_collected() -> void:
	ingredient_1_collected = true
