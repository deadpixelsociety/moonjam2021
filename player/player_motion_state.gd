extends State
class_name PlayerMotionState

export(float) var move_deadzone = 0.6
export(NodePath) onready var player = get_node(player) as Player

var movement_axis = Vector2.ZERO


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
			movement_axis = joy_dir.normalized()
		
	if movement_axis.length_squared() > 0.0:
		player.heading = movement_axis.normalized()


func _get_animation_affix() -> String:
	print(player.heading)
	
	var affix = "_side"
	if abs(player.heading.y) > abs(player.heading.x):
		if player.heading.y < 0.0:
			affix = "_up"
		elif player.heading.y > 0.0:
			affix = "_down"
		
	return affix
