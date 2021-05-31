extends Area2D
class_name Stairs

export(PackedScene) var next_level: PackedScene = null


func _on_Stairs_body_entered(body):
	var player = body as Player
	if not player:
		return
	
	disconnect("body_entered", self, "_on_Stairs_body_entered")
	
	PlayerStorage.set_player(player)
	get_tree().change_scene_to(next_level)
