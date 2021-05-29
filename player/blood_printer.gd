extends Sprite
class_name BloodPrinter

signal print_finished

onready var _animation_player := $AnimationPlayer


func print_drone():
	_animation_player.play("print")
	yield(_animation_player, "animation_finished")
	emit_signal("print_finished")
