extends PlayerMotionState
class_name PlayerIdleState

export(NodePath) onready var animated_sprite = get_node(animated_sprite) as AnimatedSprite

func enter():		
	animated_sprite.play("idle" + _get_animation_affix())


func execute(delta: float):
	.execute(delta)
	
	if movement_axis.length_squared() > 0.0:
		_finish("move")
