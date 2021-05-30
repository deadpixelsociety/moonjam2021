extends KinematicBody2D
class_name Player

signal died
signal health_changed

export(int) var max_health = 5 setget _set_max_health

var heading = Vector2(1.0, 0.0) setget _set_heading, _get_heading
var path = PoolVector2Array()
var shooting = false
var moving = false

var _health = 5

onready var _animated_sprite := $AnimatedSprite
onready var _collision := $CollisionShape2D
onready var _bullet_spawn := $BulletSpawn
onready var _core_state_machine := $CoreStateMachine
onready var _action_state_machine := $ActionStateMachine
onready var _revolver := $Revolver
onready var _revolver_right := $RevolverRight
onready var _revolver_left := $RevolvedLeft
onready var _drone_container := $DroneContainer

var _move_speed = 175.0
var _velocity = Vector2.ZERO


func _physics_process(delta):
	if path.size() > 0:
		_move_along_path(delta)
		
	if abs(heading.y) > abs(heading.x) and heading.y < 0.0:
		_revolver.z_index = -1
	else:
		_revolver.z_index = 0


func _move_along_path(delta: float):
	var current = position
	var target = path[0]

	var distance = current.distance_to(target)
	
	if distance <= 0.01:
		position = target
		path.remove(0)
		return
		
	var dir = (target - current).normalized()

	_velocity = dir * _move_speed
	
	var distance_will_travel = (_velocity * delta).length()

	if distance_will_travel <= distance and distance_will_travel > 0.0:
		move_and_slide(_velocity)
	else:
		path.remove(0)
	#elif distance_will_travel > distance and distance_will_travel > 0.0:
	#	path.remove(0)
	#elif distance_will_travel <= 0.0:
	#	path.remove(0)


func _process(delta):
	pass


func can_attach_drone() -> bool:
	if _health <= 1:
		return false
		
	var attachment = _drone_container.get_free_attachment()
	return attachment != null


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
