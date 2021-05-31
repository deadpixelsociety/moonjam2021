extends State
class_name KnockbackState


func enter():
	yield(get_tree().create_timer(1.0), "timeout")
	_finish()


func execute(delta: float):
	var gremlin = owner as Gremlin
	if gremlin:
		gremlin.knockback *= 0.9
		
		if gremlin.knockback.length() <= 0.01:
			gremlin.knockback = Vector2.ZERO
			_finish()
		
		gremlin.knockback = gremlin.move_and_slide(gremlin.knockback)
