extends Area2D
class_name Fireball

export(float) var damage = 1.0
const MOVE_SPEED = 200.0

var _heading = Vector2.ZERO


func _physics_process(delta):
	var velocity = _heading * MOVE_SPEED * delta
	position += velocity 


func fire(heading: Vector2):
	_heading = heading
	rotation = heading.angle()
	visible = true


func _on_Fireball_body_entered(body):
	visible = false
	queue_free()


func _on_Fireball_area_entered(area):
	visible = false
	queue_free()

