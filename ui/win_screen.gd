extends Control
class_name WinScreen


func _ready():
	PlayerStorage.clear_player()
	MusicManager.stop()
	get_tree().paused = false


func _on_RetryGame_pressed():
	get_tree().change_scene("res://ui/menu_screen.tscn")


func _on_QuitGame_pressed():
	get_tree().quit()
