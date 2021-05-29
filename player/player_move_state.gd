extends PlayerControlState
class_name PlayerMoveState

export(float) var move_speed = 175.0
export(float) var friction = 0.80
export(NodePath) onready var kinematic_body = get_node(kinematic_body) as KinematicBody2D

var _velocity = Vector2.ZERO


func enter():
	animated_sprite.play("move")


func execute(delta: float):
	var dir = poll_movement()
	_move_body(dir)
		
	if _velocity == Vector2.ZERO:
		_finish("idle")

	.execute(delta)


func _move_body(dir: Vector2):
	if dir.length_squared() > 0.0:
		_velocity = dir.normalized() * move_speed
	else:
		_velocity *= friction
		if _velocity.length_squared() <= .01:
			_velocity = Vector2.ZERO
	
	_velocity = kinematic_body.move_and_slide(_velocity)
	
	if _velocity.length_squared() > 0.0:
		_heading = Vector2(sign(_velocity.x), sign(_velocity.y))

