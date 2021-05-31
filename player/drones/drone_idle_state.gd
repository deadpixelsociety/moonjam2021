extends State
class_name DroneIdleState

export(NodePath) onready var animation_player = get_node(animation_player) as AnimationPlayer
export(NodePath) onready var enemy_trigger = get_node(enemy_trigger) as Area2D


func enter():
	if enemy_trigger.is_connected("body_entered", self, "_on_EnemyTrigger_body_entered"):
		enemy_trigger.disconnect("body_entered", self, "_on_EnemyTrigger_body_entered")
	enemy_trigger.connect("body_entered", self, "_on_EnemyTrigger_body_entered")
	animation_player.play("idle")


func execute(delta: float):
	_scan()


func _scan():
	var drone = owner as Drone
	if drone and not drone.target:
		var bodies = enemy_trigger.get_overlapping_bodies()
		for _body in bodies:
			var body = _body as Node2D
			if body:
				drone.track_target(body)
				drone.reacquire()
				_request_state("shoot")


func exit():
	enemy_trigger.disconnect("body_entered", self, "_on_EnemyTrigger_body_entered")


func _on_EnemyTrigger_body_entered(body):
	print("idle triggered")
	if not body is Gremlin:
		return
	
	var drone = owner as Drone
	if not drone:
		return

	var target = body as Node2D
	if not target:
		return
		
	drone.track_target(target)
	drone.reacquire()
	_request_state("shoot")
