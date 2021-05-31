extends Node


func clear_player():
	get_player()


func set_player(player: Player):
	if get_child_count() > 0:
		return		
	if player.get_parent():
		player.get_parent().remove_child(player)
	call_deferred("add_child", player)


func get_player() -> Player:
	if get_child_count() == 0: 
		return null
	
	var player = get_child(0) as Player
	remove_child(player)
	return player
