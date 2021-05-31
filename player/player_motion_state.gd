extends State
class_name PlayerMotionState

export(float) var move_deadzone = 0.6
export(NodePath) onready var player = get_node(player) as Player
export(NodePath) onready var _sfx_no_blood = get_node(_sfx_no_blood) as AudioStreamPlayer
export(NodePath) onready var _sfx_bzzt = get_node(_sfx_bzzt) as AudioStreamPlayer

var movement_axis = Vector2.ZERO


func execute(delta: float):
	poll_movement()
	
	var print_drone = false
	var type = BloodPrinter.Drones.SINGLE_SHOT
	
	if Input.is_action_just_pressed("laser"):
		print_drone = true
		type = BloodPrinter.Drones.SINGLE_SHOT
	elif Input.is_action_just_pressed("shotgun"):
		print_drone = true
		type = BloodPrinter.Drones.SHOTGUN
	elif Input.is_action_just_pressed("grenade"):
		print_drone = true
		type = BloodPrinter.Drones.GRENADE
	elif Input.is_action_just_pressed("auto"):
		print_drone = true
		type = BloodPrinter.Drones.AUTO_SHOT

	if print_drone:
		if player.has_health_to_print():
			if player.can_attach_drone():
				player.requested_drone = type
				_request_state("print")
			else:
				_sfx_bzzt.play()
		else:
			_sfx_no_blood.play()


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
	var affix = "_side"
	if abs(player.heading.y) > abs(player.heading.x):
		if player.heading.y < 0.0:
			affix = "_up"
		elif player.heading.y > 0.0:
			affix = "_down"
		
	return affix
