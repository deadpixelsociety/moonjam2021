extends Area2D
class_name Fireball

export(float) var damage = 1.0
const MOVE_SPEED = 150.0

var _heading = Vector2.ZERO
var dead = false


func _physics_process(delta):
	var velocity = _heading * MOVE_SPEED * delta
	position += velocity 


func fire(heading: Vector2):
	_heading = heading
	rotation = heading.angle()
	visible = true


func _on_Fireball_body_entered(body):
	dead = true
	visible = false
	queue_free()


func _on_Fireball_area_entered(area):
	dead = true
	visible = false
	queue_free()

