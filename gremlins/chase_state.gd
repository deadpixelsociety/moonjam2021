extends State
class_name ChaseState

export(NodePath) onready var animated_sprite = get_node(animated_sprite) as AnimatedSprite


func execute(delta: float):
	_chase()


func _chase():
	var gremlin = owner as Gremlin
	if not gremlin:
		return
		
	if not gremlin.target:
		_finish()
		return
		
	var dist = gremlin.global_position.distance_to(gremlin.target.global_position)
	var velocity = (gremlin.target.global_position - gremlin.global_position).normalized()
	velocity *= 150.0
	animated_sprite.play("move" + _get_animation_affix(velocity))
	animated_sprite.flip_h = velocity.x < 0.0
	gremlin.move_and_slide(velocity)


func _get_animation_affix(dir: Vector2) -> String:
	var affix = "_side"
	if abs(dir.y) > abs(dir.x):
		if dir.y < 0.0:
			affix = "_up"
		elif dir.y > 0.0:
			affix = "_down"
		
	return affix


func _on_BennyTrigger_body_exited(body):
	if not body is Player:
		return
	
	var gremlin = owner as Gremlin
	if not gremlin:
		return

	gremlin.target = null
	_finish()
