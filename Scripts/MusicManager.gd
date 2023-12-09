extends Node2D

@onready var audio_player = $AudioStreamPlayer as AudioStreamPlayer
@onready var music = [preload("res://Audio/Music/MainMenu.wav"), preload("res://Audio/Music/Driving_Loop.wav"), preload("res://Audio/Music/ResultsScreen_maybe.wav")]

func change_music(song_index:int):
	if song_index == -1: 
		audio_player.stop()
		return
	elif song_index < 0 || song_index > music.size(): 
		printerr("change_music(): song_index is out of range.")
		return
	
	audio_player.stream = music[song_index]
	audio_player.play()

func update_music_volume(value:float):
	audio_player.volume_db = value
