extends Drone
class_name SingleShotDrone

onready var _sprite := $Sprite
onready var _animation_player := $AnimationPlayer


func _ready():
	_animation_player.play("idle")
	

func charge_shot():
	_animation_player.play("shoot")
	yield(_animation_player, "animation_finished")
	_animation_player.play("idle")


func spawn():
	.spawn()
	_animation_player.play("spawn")
	yield(_animation_player, "animation_finished")
	_animation_player.play("idle")
