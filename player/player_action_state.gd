extends State
class_name PlayerActionState

export(float) var shoot_deadzone = 0.6
export(NodePath) onready var player = get_node(player) as Player

var shoot_axis = Vector2.ZERO

var _mouse_shooting = false


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			_mouse_shooting = event.pressed
			if event.pressed:
				poll_shoot()


func execute(delta: float):
	poll_shoot()


func poll_shoot():
	shoot_axis = Vector2.ZERO
	if _mouse_shooting:
		var mouse_pos = player.get_global_mouse_position()
		shoot_axis = Vector2(
			mouse_pos.x - player.global_position.x,
			mouse_pos.y - player.global_position.y
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
		player.heading = shoot_axis
