extends State
class_name PlayerDeathState

export(NodePath) onready var animated_sprite = get_node(animated_sprite) as AnimatedSprite
export(NodePath) onready var sfx_death = get_node(sfx_death) as AudioStreamPlayer

onready var _tween := $Tween

func enter():
	if sfx_death:
		sfx_death.play()
	
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
			if sfx_death:
				yield(sfx_death, "finished")

	player.queue_free()
	GameEvents.emit_signal("player_died")
	_finish()
