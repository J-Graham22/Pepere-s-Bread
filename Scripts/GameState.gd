extends Node

enum Character {
	JESS,
	JAMIE
}

var current_save_slot: int = 1

var last_completed_level: int = 0
var selected_character: Character = Character.JESS

func save():
	var save_dict = {
		"last_completed_level" : last_completed_level,
		"selected_character" : 0 if selected_character == Character.JESS else 1,
	}
	return save_dict

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
