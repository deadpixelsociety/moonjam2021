extends State
class_name KnockbackState

var _knockback_time = -1

func enter():
	_knockback_time = OS.get_ticks_msec()


func execute(delta: float):
	var now = OS.get_ticks_msec()
	var diff = now - _knockback_time
	if diff >= 1000.0:
		_finish()
		return
		
	var gremlin = owner as Gremlin
	if gremlin:
		gremlin.knockback *= 0.9
		
		if gremlin.knockback.length() <= 0.01:
			gremlin.knockback = Vector2.ZERO
			_finish()
		
		gremlin.knockback = gremlin.move_and_slide(gremlin.knockback)
