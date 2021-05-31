extends Area2D
class_name Bullet

const MOVE_SPEED = 300.0

export(float) var damage = 1.0

var _heading = Vector2.ZERO

func _physics_process(delta):
	var velocity = _heading * MOVE_SPEED * delta
	position += velocity 


func fire(heading: Vector2):
	_heading = heading
	rotation = heading.angle()
	visible = true


func _on_Bullet_body_entered(body):
	visible = false
	queue_free()
