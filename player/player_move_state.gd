extends PlayerMotionState
class_name PlayerMoveState

export(float) var move_speed = 175.0
export(float) var friction = 0.80
export(NodePath) onready var animated_sprite = get_node(animated_sprite) as AnimatedSprite
export(NodePath) onready var kinematic_body = get_node(kinematic_body) as KinematicBody2D

var _velocity = Vector2.ZERO


func enter():
	#animated_sprite.play("move")
	pass


func execute(delta: float):
	.execute(delta)
	
	_move_body(movement_axis)
	
	if _velocity == Vector2.ZERO:
		_finish("idle")


func _move_body(dir: Vector2):
	if dir.length_squared() > 0.0:
		_velocity = dir.normalized() * move_speed
	else:
		_velocity *= friction
		if _velocity.length_squared() <= .01:
			_velocity = Vector2.ZERO
	
	_velocity = kinematic_body.move_and_slide(_velocity)
