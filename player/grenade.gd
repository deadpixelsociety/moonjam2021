extends RigidBody2D
class_name Grenade

export(float) var damage = 1.0

onready var _explosion_radius := $ExplosionRadius
onready var _animated_sprite := $AnimatedSprite
onready var _explode := $Sounds/Explode
onready var _tink := $Sounds/Tink
onready var _explode_timer := $ExplodeTimer

var hit_gremlin = false
var velocity_adjusted = false


func _ready():
	_explode_timer.start()


func _integrate_forces(state):
	if hit_gremlin and not velocity_adjusted:
		velocity_adjusted = true
		state.linear_velocity = state.linear_velocity * 0.1


func launch(heading: Vector2):
	apply_impulse(Vector2.ZERO, heading * 300.0)
	visible = true


func _explode():
	_explode.play()

	var enemies = _explosion_radius.get_overlapping_areas()
	if not enemies or enemies.size() == 0:
		return
		
	for _enemy in enemies:
		var gremlin = _enemy.owner as Gremlin
		if gremlin:
			gremlin.hurt(damage)


func _on_Grenade_body_entered(body):
	var gremlin = body as Gremlin
	if not gremlin:
		gremlin = body.owner as Gremlin
	
	if gremlin:
		hit_gremlin = true
		
	_tink.play()


func _on_ExplodeTimer_timeout():
	_animated_sprite.play("explode")
	_explode()
	if _animated_sprite:
		yield(_animated_sprite, "animation_finished")
	visible = false
	if _explode:
		yield(_explode, "finished")
	queue_free()
