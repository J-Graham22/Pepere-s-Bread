extends Area2D

@onready var label = $Label
@onready var message_panel = %SignPanel
@onready var message: Label = %SignText

var player_in_range: bool = false
var is_jess: bool = false
var message_currently_visible: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_pressed("Confirm"):
		if message_currently_visible:
			hide_message()
		else:
			show_message()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_jess = body.is_jess()
		player_in_range = true
		label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		label.visible = false
		
		if message_currently_visible:
			hide_message()
		
func show_message():
	message_currently_visible = true
	
	if is_jess:
		message.text = "Oh look it's Jess"
	else:
		message.text = "Hey, you're not Jess"
		
	message.visible = true
	message_panel.visible = true
	
func hide_message():
	message_currently_visible = false
	
	message.visible = false
	message_panel.visible = false
	
