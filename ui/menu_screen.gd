extends Control
class_name MenuScreen

onready var _music := $MenuMusic
onready var _credits := $CreditsDialog
onready var _about := $AboutDialog
onready var _synopsis := $Synopsis


func _ready():
	_on_Volume_value_changed(90.0)


func _on_QuitGame_pressed():
	get_tree().quit()


func _on_PlayGame_pressed():
	_music.stop()
	get_tree().change_scene("res://world/start_room.tscn")


func _on_WIN_JAM_pressed():
	_credits.popup()


func _on_Volume_value_changed(value: float):
	var nrg = value / 100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(nrg))


func _on_About_pressed():	
	_about.popup()
	_synopsis.play()


func _on_AboutDialog_popup_hide():
	if _synopsis.playing:
		_synopsis.stop()
