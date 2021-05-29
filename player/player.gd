extends KinematicBody2D
class_name Player

signal died
signal health_changed

const BULLET_DEADZONE = 0.5
const MOVE_DEADZONE = 0.5

export(PackedScene) onready var Bullet
export(int) var max_health = 5 setget _set_max_health

var _shooting = false
var _health = 0

onready var _animated_sprite := $AnimatedSprite
onready var _collision := $CollisionShape2D
onready var _bullet_spawn := $BulletSpawn
onready var _state_machine := $StateMachine


func _physics_process(delta):
	pass


func _process(delta):
	pass


func _move_player():
	var dir = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	
	var joy_dir = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_0), 
		Input.get_joy_axis(0, JOY_AXIS_1)
	)

	if dir.length_squared() == 0.0 and joy_dir.length() > MOVE_DEADZONE:
		dir = Vector2(sign(joy_dir.x), sign(joy_dir.y))

	_state_machine.swap_state("move", dir)


func _died():
	_state_machine.swap_state("death")
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

