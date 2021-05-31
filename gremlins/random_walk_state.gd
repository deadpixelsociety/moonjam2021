extends State
class_name RandomWalkState

export(float) var move_speed = 125.0
export(float) var max_speed = 300.0
export(NodePath) onready var animated_sprite = get_node(animated_sprite) as AnimatedSprite
export(NodePath) onready var benny_trigger = get_node(benny_trigger) as Area2D
export(NodePath) onready var body = get_node(body) as KinematicBody2D

var _velocity = Vector2.ZERO
var _heading = Vector2.ZERO

onready var _timer := $Timer

func enter():
	randomize()
	_randomize_heading()
	animated_sprite.play("move" + _get_animation_affix())
	_timer.start()


func execute(delta: float):
	animated_sprite.play("move" + _get_animation_affix())	
	animated_sprite.flip_h = _heading.x < 0.0
	
	_velocity += _heading * move_speed
	
	if _velocity.length() > max_speed:
		_velocity = _velocity.normalized() * max_speed
		
	_velocity = body.move_and_slide(_velocity)
	if body.get_slide_count() > 0:
		_randomize_heading()


func _get_animation_affix() -> String:
	var affix = "_side"
	if abs(_heading.y) > abs(_heading.x):
		if _heading.y < 0.0:
			affix = "_up"
		elif _heading.y > 0.0:
			affix = "_down"
		
	return affix


func _randomize_heading():
	_heading = Vector2(1.0 - randf() * 2.0, 1.0 - randf() * 2.0)


func _on_Timer_timeout():
	_randomize_heading()


func _on_BennyTrigger_body_entered(body):
	if not body is Player:
		return
	
	var gremlin = owner as Gremlin
	if not gremlin or not benny_trigger:
		return

	gremlin.target = body as Node2D
	_request_state("attack")
