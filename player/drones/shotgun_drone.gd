extends Drone
class_name ShotgunDrone

onready var _sprite := $Sprite
onready var _animation_player := $AnimationPlayer
onready var _state_machine := $StateMachine
onready var _tween := $Tween
onready var _sfx_death := $Sounds/Death

var dead = false


func charge_shot():
	_animation_player.play("shoot")
	yield(_animation_player, "animation_finished")
	_animation_player.play("idle")


func spawn():
	_animation_player.play("spawn")
	yield(get_tree().create_timer(0.1), "timeout")
	visible = true
	yield(_animation_player, "animation_finished")
	connect("area_entered", self, "_on_Drone_area_entered")
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


func _on_Drone_area_entered(area):
	if not dead:
		kill()


func kill():
	dead = true
	_sfx_death.play()
	_tween.interpolate_property(
		self,
		"modulate",
		null,
		Color.transparent,
		0.2
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	queue_free()
