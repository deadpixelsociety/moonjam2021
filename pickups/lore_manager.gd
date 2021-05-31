extends Node

onready var _sfx_lore1 = preload("res://assets/sounds/saul_voicefile_1.wav")
onready var _sfx_lore2 = preload("res://assets/sounds/saul_voicefile_2.wav")
onready var _sfx_lore3 = preload("res://assets/sounds/saul_voicefile_3.wav")
onready var _sfx_lore4 = preload("res://assets/sounds/saul_voicefile_4.wav")

var lore_num = 1

var _audio_player: AudioStreamPlayer = null

func _ready():
	_audio_player = AudioStreamPlayer.new()
	add_child(_audio_player)


func play_lore():
	if _audio_player and _audio_player.playing:
		_audio_player.stop()
		
	if lore_num > 4:
		return
	
	match lore_num:
		1:
			_audio_player.stream = _sfx_lore1
		2:
			_audio_player.stream = _sfx_lore2
		3:
			_audio_player.stream = _sfx_lore3
		4:
			_audio_player.stream = _sfx_lore4

	lore_num += 1

	if _audio_player.stream:
		_audio_player.play()
		yield(_audio_player, "finished")
