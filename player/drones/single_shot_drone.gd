extends Drone
class_name SingleShotDrone

onready var _sprite := $Sprite
onready var _animation_player := $AnimationPlayer
onready var _state_machine := $StateMachine


func charge_shot():
	_animation_player.play("shoot")
	yield(_animation_player, "animation_finished")
	_animation_player.play("idle")


func spawn():
	_animation_player.play("spawn")
	visible = true
	yield(_animation_player, "animation_finished")
	_animation_player.play("idle")
	.spawn()


func attach_out():
	_animation_player.play("attach_out")
	yield(_animation_player, "animation_finished")
	.attach_out()


func attach_in():
	_animation_player.play("attach_in")
	yield(_animation_player, "animation_finished")
	_state_machine._on_state_requested("idle")
	.attach_in()
