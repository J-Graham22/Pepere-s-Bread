extends Area2D

@onready var sprite = $Sprite2D

@export var unchecked_texture: Texture2D = sprite.texture
@export var checked_texture: Texture2D = sprite.texture

var activated: bool = false

func _ready() -> void:
	if activated:
		sprite.texture = checked_texture
	else:
		sprite.texture = unchecked_texture
		
