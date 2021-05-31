extends Node
class_name GameLevel


func _ready():
	get_tree().paused = false
	GameEvents.connect("player_died", self, "_on_player_died")
	GameEvents.connect("player_dying", self, "_on_player_dying")


func _on_player_dying():
	get_tree().paused = true

func _on_player_died():
	get_tree().change_scene("res://world/game_level.tscn")
