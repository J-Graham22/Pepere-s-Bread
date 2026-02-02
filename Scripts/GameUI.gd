extends Control

@onready var score_texture = %Score/ScoreTexture
@onready var score_label = %Score/ScoreLabel

@onready var heart_0 = %PlayerHealth/Heart
@onready var heart_1 = %PlayerHealth/Heart2
@onready var heart_2 = %PlayerHealth/Heart3

func _process(_delta):
	# Set the score label text to the score variable in game maanger script
	score_label.text = "x %d" % GameManager.score


func _on_player_health_changed(current: Variant, max: Variant) -> void:
	# this is definitely not the best way to do this but whatever lol
	if current == 3:
		heart_0.visible = true
		#heart_0.show()
		heart_1.visible = true
		heart_2.visible = true
	if current == 2:
		heart_0.visible = true
		heart_1.visible = true
		heart_2.visible = false
	if current == 1:
		heart_0.visible = true
		heart_1.visible = false
		heart_2.visible = false
	if current == 0:
		heart_0.visible = false
		heart_1.visible = false
		heart_2.visible = false
