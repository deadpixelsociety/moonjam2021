extends Area2D
class_name Stairs

export(PackedScene) var next_level: PackedScene = null


func _on_Stairs_body_entered(body):
	var player = body as Player
	if not player:
		return
	
	disconnect("body_entered", self, "_on_Stairs_body_entered")
	
	if LevelManager.current_level <= 4:
		PlayerStorage.set_player(player)
		LevelManager.current_level += 1
	else:
		PlayerStorage.clear_player()
	get_tree().change_scene_to(next_level)
