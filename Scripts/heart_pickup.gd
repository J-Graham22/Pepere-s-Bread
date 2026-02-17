extends Area2D

@export var amplitude := 4
@export var frequency := 5

var time_passed = 0
var initial_position := Vector2.ZERO

func _ready():
	initial_position = position

func _process(delta):
	hover(delta) 

# Ingredient Hover Animation
func hover(delta):
	time_passed += delta
	
	var new_y = initial_position.y + amplitude * sin(frequency * time_passed)
	position.y = new_y

# Ingredient collected
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if not body.is_at_max_health():
			AudioManager.coin_pickup_sfx.play()
			body.heal()
			var tween = create_tween()
			tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
			await tween.finished
			queue_free()
