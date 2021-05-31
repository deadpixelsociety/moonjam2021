extends State
class_name FireballState

export(float) var fireball_cooldown = 1.0
export(PackedScene) var Fireball
export(NodePath) onready var animated_sprite = get_node(animated_sprite) as AnimatedSprite
export(NodePath) onready var shoot_origin = get_node(shoot_origin) as Node2D

var _last_fire = -1


func enter():
	_fire()


func execute(delta: float):
	_fire()
	_chase()


func _chase():
	var gremlin = owner as Gremlin
	if not gremlin:
		return
		
	if not gremlin.target:
		return
		
	var dist = gremlin.global_position.distance_to(gremlin.target.global_position)
	
	if dist > 175.0:
		var velocity = (gremlin.target.global_position - gremlin.global_position).normalized()
		velocity *= 75.0
		gremlin.move_and_slide(velocity)


func _fire():
	var gremlin = owner as Gremlin
	if not gremlin:
		return
		
	if not gremlin.target:
		return

	var now = OS.get_ticks_msec()
	var diff = now - _last_fire
	var cooldown_msec = fireball_cooldown * 1000.0
	if _last_fire == -1 or diff >= cooldown_msec:
		_last_fire = now
		
		var dir = (gremlin.target.global_position - gremlin.global_position).normalized()
		animated_sprite.play("move" + _get_animation_affix(dir))
		animated_sprite.flip_h = dir.x < 0.0
		
		shoot_origin.position = dir * 18.0
		
		var fireball = Fireball.instance() as Fireball
		fireball.global_position = shoot_origin.global_position
		fireball.fire(dir)
		
		var entities = get_tree().root.find_node("Entities", true, false) as YSort
		if entities:
			entities.call_deferred("add_child", fireball)


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
