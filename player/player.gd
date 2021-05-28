extends KinematicBody2D
class_name Player

const BULLET_COOLDOWN = 0.75
const BULLET_DEADZONE = 0.5
const FRICTION = 0.85
const MOVE_DEADZONE = 0.5
const MOVE_SPEED = 175.0

export(PackedScene) onready var Bullet

var _velocity = Vector2.ZERO
var _heading = Vector2(1.0, 0.0)
var _bullet_timer = 0.0
var _firing = false

onready var _animated_sprite := $AnimatedSprite
onready var _collision := $CollisionShape2D
onready var _bullet_spawn := $BulletSpawn


func _physics_process(delta):
	_move_player()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			_firing = event.pressed


func _process(delta):
	if _bullet_timer > 0.0:
		_bullet_timer = max(_bullet_timer - delta, 0.0)

	var fire_dir = Vector2.ZERO
	if _firing:
		var mouse_pos = get_global_mouse_position()
		fire_dir = Vector2(
			mouse_pos.x - _bullet_spawn.global_position.x,
			mouse_pos.y - _bullet_spawn.global_position.y
		).normalized()
	else:
		fire_dir = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_2), 
			Input.get_joy_axis(0, JOY_AXIS_3)
		)
		
		if fire_dir.length() < BULLET_DEADZONE:
			fire_dir = Vector2.ZERO
	
	if fire_dir.length_squared() > 0.0:
		_fire(fire_dir)


func _fire(dir: Vector2):
	if _bullet_timer <= 0.0:
		_bullet_timer = BULLET_COOLDOWN
		var bullet = Bullet.instance() as Bullet
		bullet.global_position = _bullet_spawn.global_position
		bullet.fire(dir)
		owner.add_child(bullet)


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
	
	if dir.length_squared() > 0.0:
		_heading = dir.normalized()
		_velocity = _heading * MOVE_SPEED
	else:
		_velocity *= FRICTION
		if _velocity.length_squared() <= .01:
			_velocity = Vector2.ZERO
	
	_animated_sprite.flip_h = _heading.x < 0.0	
	
	move_and_slide(_velocity)
