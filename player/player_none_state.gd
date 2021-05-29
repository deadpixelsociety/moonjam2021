extends PlayerActionState
class_name PlayerNoneState


func execute(delta: float):
	.execute(delta)
	
	if shoot_axis.length_squared() > 0.0:
		_request_state("shoot")
