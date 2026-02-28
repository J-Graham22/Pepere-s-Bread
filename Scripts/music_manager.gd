extends Node

@onready var player: AudioStreamPlayer = $AudioStreamPlayer

var current_track: AudioStream = null

func _ready():
	print("MusicManager ready")

func play_music(stream: AudioStream):
	if current_track == stream and player.playing:
		return  # Prevent restarting same song
		
	if stream == null:
		player.stop()

	current_track = stream
	player.stream = stream

	#if stream is AudioStreamWAV:
		#stream.loop_mode = 1
		#stream.loop_begin = 0
		#stream.loop_end = current_track.get_length()

	print('ok play the fucking song')
	player.play()
	print(player.playing)

func stop_music():
	player.stop()


func _on_audio_stream_player_finished() -> void:
	print('fuck off, this is the only thing you have')
	print(player.stream)
	print(player.stream.get_length())
