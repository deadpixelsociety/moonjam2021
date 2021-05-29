extends PlayerControlState
class_name PlayerIdleState


func enter():
	animated_sprite.play("idle")


func execute(delta: float):
	.execute(delta)
	
	var movement = poll_movement()
	if movement.length_squared() > 0.0:
		_finish("move")

	var shoot_dir = poll_shoot()
	if shoot_dir.length_squared() > 0.0:
		_heading = shoot_dir.normalized()
		
	_flip_sprite()
