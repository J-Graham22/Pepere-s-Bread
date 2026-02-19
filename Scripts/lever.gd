extends Area2D

@onready var label = $Label
@onready var water_tiles: TileMapLayer = %Background
@onready var water_hitbox: Area2D = %Water
@onready var sprite: Sprite2D = $Sprite2D
@onready var fish_group = %FishGroup

var player_in_range: bool = false
var is_jess: bool = false
var is_water_enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_pressed("Confirm"):
		if is_water_enabled:
			is_water_enabled = false
			
			water_hitbox.visible = false
			water_hitbox.queue_free()
			water_hitbox.monitoring = false
			water_hitbox.process_mode = Node.PROCESS_MODE_DISABLED
			
			water_tiles.process_mode = Node.PROCESS_MODE_DISABLED
			water_tiles.visible = false
			sprite.flip_h = !sprite.flip_h
			
			var fish = fish_group.get_children()
			for f in fish:
				f.set_in_water(false)
			

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_jess = body.is_jess()
		player_in_range = true
		label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		label.visible = false
		
	
