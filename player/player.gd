extends KinematicBody2D
class_name Player

signal died
signal health_changed

export(int) var max_health = 5 setget _set_max_health

var heading = Vector2(1.0, 0.0) setget _set_heading, _get_heading
var path = PoolVector2Array()

var _health = 0

onready var _animated_sprite := $AnimatedSprite
onready var _collision := $CollisionShape2D
onready var _bullet_spawn := $BulletSpawn
onready var _core_state_machine := $CoreStateMachine
onready var _action_state_machine := $ActionStateMachine
onready var _revolver := $Revolver
onready var _revolver_right := $RevolverRight
onready var _revolver_left := $RevolvedLeft

var _move_speed = 175.0
var _velocity = Vector2.ZERO


func _physics_process(delta):
	if path.size() > 0:
		_move_along_path(delta)


func _move_along_path(delta: float):
	var start = position
	for i in range(path.size()):
		var dir = (path[0] - start).normalized()
		
		_velocity = dir * _move_speed
		
		var distance = _velocity.length()
		if distance <= .01:
			_velocity = Vector2.ZERO
		
		distance *= delta
		
		var distance_to_next = start.distance_to(path[0])
		if distance <= distance_to_next and distance > 0.0:
			_velocity = move_and_slide(_velocity)
		elif distance > distance_to_next and distance > 0.0:
			var tween = Tween.new()
			tween.interpolate_property(
				self,
				"position",
				null,
				path[0],
				0.25
			)
			
			tween.start()
			yield(tween, "tween_all_completed")
			path.remove(0)
		elif distance <= 0.0:
			path.remove(0)
		
		if path.size() == 0:
			break

		start = position
		distance_to_next = start.distance_to(path[0])
		if distance_to_next <= 0.01:
			path.remove(0)


func _process(delta):
	pass


func _died():
	_core_state_machine.swap_state("death")
	emit_signal("died")


func _set_max_health(value: float):
	max_health = value
	var old_health = _health
	_health = value
	_health_changed(old_health, _health)


func _health_changed(old_health: float, new_health: float):
	emit_signal("health_changed", old_health, new_health)


func consume_health(amount: float):
	var old_health = _health
	_health = max(_health - amount, 0.0)
	_health_changed(old_health, _health)

	if _health <= 0.0:
		_died()


func _set_heading(value: Vector2):
	heading = value
	_flip_sprite()


func _get_heading() -> Vector2:
	return heading


func _flip_sprite():
	if heading.x != 0.0:
		_animated_sprite.flip_h = heading.x < 0.0
	
	_place_revolver()


func _place_revolver():
	if heading.x != 0.0:
		_revolver.flip_h = heading.x > 0.0
	
		if heading.x < 0.0:
			_revolver.position = _revolver_left.position
		else:
			_revolver.position = _revolver_right.position
