extends Node

func save_game(save_slot: int, last_completed_level: int):
	if save_slot <= 0 or save_slot >= 4: #valid numbers are 1,2,3
		return
		
	var save_path = get_slot_path(save_slot)
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	
	save_file.store_8(last_completed_level)
	save_file.close()

func load_game(save_slot: int):
	var save_path = get_slot_path(save_slot)

	if not FileAccess.file_exists(save_path):
		return

	var save_file = FileAccess.open(save_path, FileAccess.READ)
	var last_completed_level = save_file.get_8()
	save_file.close()
	
	return last_completed_level

func get_slot_path(slot: int): 
	return "user://savegame_%d.save" % slot
