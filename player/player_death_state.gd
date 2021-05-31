extends State
class_name PlayerDeathState

export(NodePath) onready var animated_sprite = get_node(animated_sprite) as AnimatedSprite

onready var _tween := $Tween

func enter():
	#animated_sprite.play("death")
	#yield(animated_sprite, "animation_finished")
	var player = owner as Player
	if player:
		GameEvents.emit_signal("player_dying")
		_tween.interpolate_property(
			player,
			"modulate",
			null,
			Color.transparent,
			1.0
		)
		_tween.start()
		if _tween:
			yield(_tween, "tween_all_completed")
			print("tween done")
	
	print("died")
	player.queue_free()
	GameEvents.emit_signal("player_died")
	_finish()
