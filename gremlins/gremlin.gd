extends KinematicBody2D
class_name Gremlin

signal died
signal hurt

export(int) var max_health: int setget _set_max_health, _get_max_health
export(float) var drop_chance = 0.3
export(float) var kraft_chance = 0.25

var target: Node2D = null
var knockback := Vector2.ZERO
var health = 3
var dead = false

onready var _sprite := $AnimatedSprite
onready var _hurtbox := $Hurtbox
onready var _tween := $Tween
onready var _state_machine := $StateMachine
onready var _health_pack = load("res://pickups/health_pack.tscn") as PackedScene
onready var _kraft_singles = load("res://pickups/kraft_singles.tscn") as PackedScene


func _on_Hurtbox_area_entered(area):
	var bullet = area as Bullet
	if not bullet:
		return
	
	bullet.visible = false
	bullet.queue_free()
	hurt(bullet.damage)


func hurt(damage: float = 1.0):
	print("hurt")
	health -= damage
	emit_signal("hurt", damage)
	if health <= 0:
		die()


func _spawn_pickup():
	if randf() <= drop_chance:
		var pickup: Node2D = null
		if randf() <= kraft_chance:
			pickup = _kraft_singles.instance() as Node2D
		else:
			pickup = _health_pack.instance() as Node2D
		
		if pickup:
			pickup.global_position = global_position
			var objects = get_tree().root.find_node("Objects", true, false) as Node
			if objects:
				objects.call_deferred("add_child", pickup)


func die():
	dead = true
	
	_spawn_pickup()
	
	if _hurtbox.is_connected("area_entered", self, "_on_Hurtbox_area_entered"):
		_hurtbox.disconnect("area_entered", self, "_on_Hurtbox_area_entered")
	
	_state_machine.set_process(false)
	_state_machine.set_physics_process(false)
	
	_tween.interpolate_property(
		_sprite,
		"modulate",
		null,
		Color(1.0, 0.0, 0.0, 0.0),
		1.0
	)
	_tween.start()
	if _tween:
		yield(_tween, "tween_all_completed")
	
	emit_signal("died", self)
	queue_free()


func _set_max_health(value: int):
	max_health = value
	health = value


func _get_max_health() -> int:
	return max_health


func do_knockback(from: Vector2):
	if _state_machine.has_state("knockback"):
		knockback = (global_position - from).normalized() * 200.0
		_state_machine._on_state_requested("knockback")


func _on_Hurtbox_body_entered(node):
	pass
