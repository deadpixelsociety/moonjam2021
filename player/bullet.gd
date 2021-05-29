extends Area2D
class_name Bullet

const MOVE_SPEED = 300.0

var _heading = Vector2.ZERO

onready var _visibility_notifier := $VisibilityNotifier2D

func _physics_process(delta):
	var velocity = _heading * MOVE_SPEED * delta
	position += velocity 
	
	if not _visibility_notifier.is_on_screen():
		queue_free()


func fire(heading: Vector2):
	_heading = heading
	rotation = heading.angle()
	visible = true


func _on_Bullet_body_entered(body):
	visible = false
	queue_free()
