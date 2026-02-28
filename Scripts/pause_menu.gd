extends CanvasLayer

@onready var main_menu: PackedScene = preload("res://Scenes/Levels/TitleScreen.tscn")

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("Pause"):
		toggle_pause()

func toggle_pause():
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func pause_game():
	get_tree().paused = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func resume_game():
	print(Input.mouse_mode)
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print(Input.mouse_mode)


func _on_resume_pressed() -> void:
	resume_game()


func _on_quit_to_menu_pressed() -> void:
	#resume_game()
	get_tree().paused = false
	visible = false
	# todo: set this to load main menu
	SceneTransition.load_scene(main_menu)


func _on_quit_to_desktop_pressed() -> void:
	resume_game()
	get_tree().quit()
