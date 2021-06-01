extends Control
class_name DeathScreen

onready var _lost := $Lost


func _ready():
	MusicManager.stop()
	get_tree().paused = false


func _on_LostTimer_timeout():
	_lost.play()


func _on_RetryGame_pressed():
	LevelManager.current_level = 0
	_lost.stop()
	$MenuMusic.stop()
	get_tree().change_scene("res://world/start_room.tscn")


func _on_QuitGame_pressed():
	get_tree().quit()
