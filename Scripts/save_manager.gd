extends Node

const SAVE_PATH := "user://savegame.json"

#TODO TODO, fix all this later, too tired now

func save_game():
	var data = {
		"player": get_node("/root/Main/Player").get_save_data(),
		"world": get_node("/root/Main/World").get_save_data()
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	get_node("/root/Main/Player").load_save_data(data["player"])
	get_node("/root/Main/World").load_save_data(data["world"])

func get_slot_path(slot: int): 
	return "user://save_slot_%d.json" % slot
