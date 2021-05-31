extends KinematicBody2D
class_name Player

signal died
signal health_changed

export(int) var max_health = 5 setget _set_max_health

var heading = Vector2(1.0, 0.0) setget _set_heading, _get_heading
var knockback = Vector2.ZERO
var shooting = false
var moving = false
var requested_drone = null

var _health = 5

onready var _animated_sprite := $AnimatedSprite
onready var _collision := $CollisionShape2D
onready var _bullet_spawn := $Revolver/BulletSpawn
onready var _core_state_machine := $CoreStateMachine
onready var _action_state_machine := $ActionStateMachine
onready var _revolver := $Revolver
onready var _revolver_right := $RevolverRight
onready var _revolver_left := $RevolvedLeft
onready var _drone_container := $DroneContainer


var _move_speed = 175.0
var _velocity = Vector2.ZERO
var _health_sent = false


func _physics_process(delta):		
	if abs(heading.y) > abs(heading.x) and heading.y < 0.0:
		_revolver.z_index = -1
	else:
		_revolver.z_index = 0


func _process(delta):
	if not _health_sent:
		_health_sent = true
		_health_changed(max_health, max_health)
	
	if Input.is_action_just_pressed("consume"):
		var drone = _drone_container.get_random_drone()
		if drone:
			consume_health(-1.0)
			drone.call_deferred("kill")
	

func has_health_to_print() -> bool:
	return _health > 1


func can_attach_drone() -> bool:
	var attachment = _drone_container.get_free_attachment()
	return attachment != null


func hurt():
	consume_health(1)


func _died():
	_core_state_machine._on_state_finished("death")
	_action_state_machine.set_physics_process(false)
	_action_state_machine.set_process(false)


func _set_max_health(value: float):
	max_health = value
	var old_health = _health
	_health = value
	_health_changed(old_health, _health)


func _health_changed(old_health: float, new_health: float):
	GameEvents.emit_signal("health_changed", int(new_health))
	emit_signal("health_changed", old_health, new_health)


func can_gain_health() -> bool:
	return _health < max_health


func consume_health(amount: float):
	var old_health = _health
	_health = min(max(_health - amount, 0.0), max_health)
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


func _on_Hurtbox_entered(node):
	#if not node is Gremlin or not node is Fireball:
	#	return
	
	consume_health(1.0)

	var gremlin = node as Gremlin
	if gremlin:
		gremlin.do_knockback(global_position)
