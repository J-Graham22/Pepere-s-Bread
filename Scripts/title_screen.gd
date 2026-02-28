extends Control

@export var level_music : AudioStream

@onready var start_screen = $StartScreen
@onready var save_slots_panel = $SaveSlotsPanel
@onready var character_select = $CharacterSelect
@onready var save_slot_info = $SaveSlotInfo

@onready var slot1 = %Slot1
@onready var slot2 = %Slot2
@onready var slot3 = %Slot3

@onready var save_info = %SaveInfo

@onready var level1: PackedScene = preload("res://Scenes/Levels/Level_01.tscn")
@onready var level2: PackedScene = preload("res://Scenes/Levels/Level_02.tscn")
@onready var level3: PackedScene = preload("res://Scenes/Levels/Level_03.tscn")
@onready var level4: PackedScene = preload("res://Scenes/Levels/Level_04.tscn")
@onready var level5: PackedScene = preload("res://Scenes/Levels/Level_05.tscn")

@onready var intro_cutscene: PackedScene = preload("res://Scenes/Cutscenes/IntroCutscene.tscn")

func _ready() -> void:
	MusicManager.play_music(level_music)

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
		SaveManager.load_game(slot)
		show_save_info()
		#load_save_file(slot)
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
	SceneTransition.load_scene(intro_cutscene)
	
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
			
func show_save_info():
	var current_level = GameState.last_completed_level + 1
	var level_info = "Level %d" % current_level
	
	var current_character = ""
	if GameState.selected_character == GameState.Character.JESS:
		current_character = "Jess"
	else:
		current_character = "Jami3"
		
	var save_desc = "%s, %s" % [level_info, current_character]
	save_info.text = save_desc
	
	save_slots_panel.visible = false
	save_slot_info.visible = true
	
func hide_save_info():
	save_slots_panel.visible = true
	save_slot_info.visible = false


func _on_load_pressed() -> void:
	load_save_file(GameState.current_save_slot)

func _on_delete_pressed() -> void:
	SaveManager.delete_save(GameState.current_save_slot)
	populate_save_slots()
	hide_save_info()

func _on_save_slot_info_back_pressed() -> void:
	hide_save_info()
