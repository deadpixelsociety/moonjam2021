extends Node
class_name EndRoom

export(NodePath) onready var player_spawn = get_node(player_spawn) as Node2D


func _ready():
	get_tree().paused = false
	MusicManager.play()
	add_player()
	$Objects/AnimatedSprite.play()
	$Objects/AnimatedSprite2.play()


func add_player():
	var player = PlayerStorage.get_player()
	if player and player_spawn:
		player.global_position = player_spawn.global_position
		add_child(player)

