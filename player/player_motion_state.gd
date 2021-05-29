extends State
class_name PlayerMotionState

export(float) var move_deadzone = 0.6
export(NodePath) onready var player = get_node(player) as Player

var movement_axis = Vector2.ZERO

var _heading = Vector2(1.0, 0.0)


func execute(delta: float):
	poll_movement()
	
	if Input.is_action_just_pressed("print_drone"):
		_request_state("print")


func poll_movement():
	movement_axis = Vector2.ZERO
	
	movement_axis.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	movement_axis.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if movement_axis.length_squared() == 0.0:
		var joy_dir = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_0), 
			Input.get_joy_axis(0, JOY_AXIS_1)
		)

		if joy_dir.length() > move_deadzone:
			movement_axis = Vector2(sign(joy_dir.x), sign(joy_dir.y))
		
	if movement_axis.length_squared() > 0.0:
		player.heading = movement_axis.normalized()
