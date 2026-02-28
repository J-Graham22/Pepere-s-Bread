extends Node2D

@export var level_music: AudioStream
# Called when the node enters the scene tree for the first time.
func _ready():
	print('playing music!')
	MusicManager.play_music(level_music)
	#RenderingServer.set_default_clear_color(Color(1, 0, 1)) # bright magenta
