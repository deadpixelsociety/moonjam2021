extends Node

var _music: AudioStreamPlayer = null

onready var cargo = preload("res://assets/music/cargo.mp3")
onready var amplify = preload("res://assets/music/amplify.mp3")


func _ready():
	_music = AudioStreamPlayer.new()
	add_child(_music)


func play(song):
	if not _music or _music.stream == song:
		return
	stop()
	_music.stream = song
	_music.play()


func stop():
	if not _music or not _music.playing:
		return	
	_music.stop()
