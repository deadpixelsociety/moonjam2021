extends State
class_name PlayerControlState

export(float) var move_deadzone = 0.6
export(float) var shoot_deadzone = 0.6
export(float) var bullet_cooldown = 0.80
export(PackedScene) var Bullet
export(NodePath) onready var animated_sprite = get_node(animated_sprite) as AnimatedSprite
export(NodePath) onready var host = get_node(host) as Node
export(NodePath) onready var shoot_origin = get_node(shoot_origin) as Node2D
export(NodePath) onready var revolver = get_node(revolver) as Sprite
export(NodePath) onready var revolver_left = get_node(revolver_left) as Node2D
export(NodePath) onready var revolver_right = get_node(revolver_right) as Node2D

var movement_axis = Vector2.ZERO
var shoot_axis = Vector2.ZERO
var _shooting = false
var _last_fire = -1
var _heading = Vector2(1.0, 0.0)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			_shooting = event.pressed
			poll_shoot()


func execute(delta: float):
	var shoot_dir = poll_shoot()
	if shoot_dir.length_squared() > 0.0:
		_shoot()
		
	if Input.is_action_just_pressed("print_drone"):
		_request_state("print")
	
	_flip_sprite()


func _shoot():
	var now = OS.get_ticks_msec()
	var diff = now - _last_fire
	var cd = bullet_cooldown * 1000.0
	if _last_fire == -1 or (diff >= cd):
		_last_fire = now
		var bullet = Bullet.instance() as Bullet
		bullet.global_position = shoot_origin.global_position

		if _heading.x < 0.0:
			revolver.rotation = PI + _heading.angle()
		else:
			revolver.rotation = _heading.angle()

		var dir = poll_shoot()
		bullet.fire(dir)
		if host and host.owner:
			host.owner.add_child(bullet)


func poll_movement() -> Vector2:
	movement_axis = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		movement_axis.x -= 1
	if Input.is_action_pressed("move_right"):
		movement_axis.x += 1
	if Input.is_action_pressed("move_up"):
		movement_axis.y -= 1
	if Input.is_action_pressed("move_down"):
		movement_axis.y += 1
	
	var joy_dir = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_0), 
		Input.get_joy_axis(0, JOY_AXIS_1)
	)

	if movement_axis.length_squared() == 0.0 and joy_dir.length() > move_deadzone:
		movement_axis = Vector2(sign(joy_dir.x), sign(joy_dir.y))
	
	return movement_axis


func poll_shoot() -> Vector2:
	var shoot_axis = Vector2.ZERO
	if _shooting:
		var mouse_pos = host.get_global_mouse_position()
		shoot_axis = Vector2(
			mouse_pos.x - host.global_position.x,
			mouse_pos.y - host.global_position.y
		).normalized()
	else:
		shoot_axis = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_2), 
			Input.get_joy_axis(0, JOY_AXIS_3)
		)
		
		if shoot_axis.length() < shoot_deadzone:
			shoot_axis = Vector2.ZERO
		else:
			shoot_axis = shoot_axis.normalized()

	if shoot_axis.length_squared() > 0.0:
		_heading = shoot_axis.normalized()
		if _heading.x < 0.0:
			shoot_origin.position = Vector2(-6.0, -1.0)
		else:			
			shoot_origin.position = Vector2(6.0, -1.0)	
			
	return shoot_axis


func _flip_sprite():
	animated_sprite.flip_h = _heading.x < 0.0
	_place_revolver()
	
func _place_revolver():
	revolver.flip_h = _heading.x > 0.0
	
	if _heading.x < 0.0:
		revolver.position = revolver_left.position
	else:
		revolver.position = revolver_right.position
