extends Node
class_name RandomLevel


func _ready():
	get_tree().paused = false
	GameEvents.connect("player_died", self, "_on_player_died")
	GameEvents.connect("player_dying", self, "_on_player_dying")
	$DungeonGenerator.generate_dungeon()
	var player = PlayerStorage.get_player()
	if player:
		player.global_position = $Objects/PlayerSpawn.global_position
		$Entities.add_child(player)


func _on_player_dying():
	get_tree().paused = true


func _on_player_died():
	PlayerStorage.clear_player()
	get_tree().change_scene("res://world/start_room.tscn")
