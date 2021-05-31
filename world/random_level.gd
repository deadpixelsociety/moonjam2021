extends Node
class_name RandomLevel

var _player: Player = null
var _stairs: Stairs = null

func _ready():
	get_tree().paused = false
	GameEvents.connect("player_died", self, "_on_player_died")
	GameEvents.connect("player_dying", self, "_on_player_dying")
	$DungeonGenerator.generate_dungeon()
	var player = PlayerStorage.get_player()
	if player:
		_player = player
		player.global_position = $Objects/PlayerSpawn.global_position
		$Entities.add_child(player)
		
	_stairs = (load("res://world/stairs.tscn") as PackedScene).instance() as Stairs
	if LevelManager.current_level < 3:
		_stairs.next_level = load("res://world/random_level.tscn") as PackedScene
	else:
		_stairs.next_level = load("res://world/end_room.tscn") as PackedScene
	_stairs.global_position = $Objects/StairsSpawn.global_position
	$Objects.add_child(_stairs)
	
	if LevelManager.current_level % 2 == 0:
		MusicManager.play(MusicManager.amplify)
	else:
		MusicManager.play(MusicManager.cargo)


func _process(delta):
	if _player and _stairs:
		var dir = (_stairs.global_position - _player.global_position).normalized()
		GameEvents.emit_signal("guide_arrow_updated", dir)


func _on_player_dying():
	LoreManager.reset()
	get_tree().paused = true


func _on_player_died():
	PlayerStorage.clear_player()
	get_tree().change_scene("res://world/start_room.tscn")
