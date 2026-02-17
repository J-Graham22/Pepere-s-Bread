extends Area2D

@onready var sprite = $Sprite2D

@export var sprite_w = 64
@export var sprite_h = 64

var activated: bool = false

func _ready() -> void:
	if activated:
		set_active()
	else:
		set_inactive()
		
func set_active():
	sprite.region_enabled = true
	sprite.region_rect = Rect2(8 * 64, 0, sprite_h, sprite_w)
	pass
	
func set_inactive():
	sprite.region_enabled = true
	sprite.region_rect = Rect2(7 * 64, 0, sprite_h, sprite_w)
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not activated:
			set_active()
			body.set_checkpoint(self.global_position)
	pass # Replace with function body.
