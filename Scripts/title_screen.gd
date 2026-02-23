extends Control

@onready var start_screen = $StartScreen
@onready var save_slots_panel = $SaveSlotsPanel
@onready var character_select = $CharacterSelect

@onready var slot1 = %Slot1
@onready var slot2 = %Slot2
@onready var slot3 = %Slot3

@onready var level1: PackedScene = preload("res://Scenes/Levels/Level_01.tscn")
@onready var level2: PackedScene = preload("res://Scenes/Levels/Level_02.tscn")
@onready var level3: PackedScene = preload("res://Scenes/Levels/Level_03.tscn")
@onready var level4: PackedScene = preload("res://Scenes/Levels/Level_04.tscn")
@onready var level5: PackedScene = preload("res://Scenes/Levels/Level_05.tscn")

func _on_start_pressed() -> void:
	populate_save_slots()
	start_screen.visible = false
	save_slots_panel.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_slot_1_pressed() -> void:
	handle_slot_clicked(1)

func _on_slot_2_pressed() -> void:
	handle_slot_clicked(2)

func _on_slot_3_pressed() -> void:
	handle_slot_clicked(3)
	
func handle_slot_clicked(slot: int):
	GameState.current_save_slot = slot
	if check_save_exists(slot):
		load_save_file(slot)
	else:
		save_slots_panel.visible = false
		character_select.visible = true


func _on_back_pressed() -> void:
	save_slots_panel.visible = false
	start_screen.visible = true
	
func populate_save_slots():
	if check_save_exists(1):
		SaveManager.load_game(1)
		var current_level = GameState.last_completed_level + 1
		slot1.text = "Level %d" % current_level
	else:
		slot1.text = "New Game"
		
	if check_save_exists(2):
		SaveManager.load_game(2)
		var current_level = GameState.last_completed_level + 1
		slot2.text = "Level %d" % current_level
	else:
		slot2.text = "New Game"
		
	if check_save_exists(3):
		SaveManager.load_game(3)
		var current_level = GameState.last_completed_level + 1
		slot3.text = "Level %d" % current_level
	else:
		slot3.text = "New Game"
	
func check_save_exists(slot: int) -> bool:
	return SaveManager.save_exists(slot)


func _on_jess_pressed() -> void:
	create_new_game_and_start(GameState.current_save_slot, GameState.Character.JESS)


func _on_jamie_pressed() -> void:
	create_new_game_and_start(GameState.current_save_slot, GameState.Character.JAMIE)


func _on_character_back_pressed() -> void:
	character_select.visible = false
	save_slots_panel.visible = true
	
func create_new_game_and_start(slot: int, character: GameState.Character):
	GameState.current_save_slot = slot
	GameState.last_completed_level = 0
	GameState.selected_character = character
	
	SaveManager.save_game()
	load_level(GameState.last_completed_level + 1)
	
func load_save_file(slot: int):
	SaveManager.load_game(slot)
	load_level(GameState.last_completed_level + 1)
	
func load_level(level: int):
	match level:
		1:
			SceneTransition.load_scene(level1)
		2:
			SceneTransition.load_scene(level2)
		3:
			SceneTransition.load_scene(level3)
		4:
			SceneTransition.load_scene(level4)
		5:
			SceneTransition.load_scene(level5)
