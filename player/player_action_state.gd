extends State
class_name PlayerActionState

export(float) var shoot_deadzone = 0.6
export(NodePath) onready var player = get_node(player) as Player
export(NodePath) onready var _sfx_no_blood = get_node(_sfx_no_blood) as AudioStreamPlayer
export(NodePath) onready var _sfx_bzzt = get_node(_sfx_bzzt) as AudioStreamPlayer

var shoot_axis = Vector2.ZERO

var _mouse_shooting = false


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			_mouse_shooting = event.pressed
			if event.pressed:
				player.shooting = true
				poll_shoot()
			else:
				player.shooting = false


func execute(delta: float):
	poll_shoot()
	poll_print()


func poll_print():
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
			player.shooting = false
			shoot_axis = Vector2.ZERO
		else:
			player.shooting = true
			shoot_axis = shoot_axis.normalized()

	if shoot_axis.length_squared() > 0.0:
		player.heading = shoot_axis


func _get_animation_affix() -> String:
	var affix = "_side"
	if abs(player.heading.y) > abs(player.heading.x):
		if player.heading.y < 0.0:
			affix = "_up"
		elif player.heading.y > 0.0:
			affix = "_down"
		
	return affix
