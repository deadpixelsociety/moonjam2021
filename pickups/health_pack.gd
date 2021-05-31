extends Area2D
class_name HealthPack

onready var _sfx_pickup := $Sounds/Pickup
onready var _tween := $Tween


func _on_HealthPack_body_entered(body):
	var player = body as Player
	if not player:
		return

	if not player.can_gain_health():
		return 

	player.consume_health(-1.0)
	_sfx_pickup.play()
	_tween.interpolate_property(
		self,
		"modulate",
		null,
		Color.transparent,
		0.3
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	if _sfx_pickup and _sfx_pickup.playing:
		yield(_sfx_pickup, "finished")
	queue_free()
