extends Node

func save_game():
	var save_slot = GameState.current_save_slot
	
	if save_slot <= 0 or save_slot >= 4: #valid numbers are 1,2,3
		return
		
	var save_path = get_slot_path(save_slot)
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	
	var json_save = JSON.stringify(GameState.save())
	save_file.store_line(json_save)
	save_file.close()

func load_game(save_slot: int):
	var save_path = get_slot_path(save_slot)

	if not FileAccess.file_exists(save_path):
		return

	var save_file = FileAccess.open(save_path, FileAccess.READ)
	
	var json_string = save_file.get_line()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
		
	var dict = json.data
	
	GameState.last_completed_level = dict['last_completed_level']
	GameState.selected_character = GameState.Character.JESS if dict['selected_character'] == 0 else GameState.Character.JAMIE
	GameState.current_save_slot = save_slot
	
func save_exists(save_slot: int):
	var save_path = get_slot_path(save_slot)

	if FileAccess.file_exists(save_path):
		print('save exists')
		return true
	else:
		print('save does not exist')
		return false

func get_slot_path(slot: int): 
	return "user://savegame_%d.save" % slot
