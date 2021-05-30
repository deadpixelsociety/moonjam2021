extends State
class_name DroneIdleState

export(NodePath) onready var animation_player = get_node(animation_player) as AnimationPlayer

func enter():
	animation_player.play("idle")
