extends CanvasLayer

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
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_resume_pressed() -> void:
	resume_game()


func _on_quit_to_menu_pressed() -> void:
	get_tree().paused = false
	# todo: set this to load main menu
	get_tree().quit()


func _on_quit_to_desktop_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
