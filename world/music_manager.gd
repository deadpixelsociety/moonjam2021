extends Node

var _music: AudioStreamPlayer = null

onready var _songs = [
	load("res://assets/music/cargo.mp3"), 
	load("res://assets/music/amplify.mp3")
]

var index = 0

func _ready():
	_music = AudioStreamPlayer.new()
	add_child(_music)


func play():
	stop()
	_music.stream = _songs[index]
	_music.play()
	index += 1
	index %= 2


func stop():
	if not _music or not _music.playing:
		return	
	_music.stop()
