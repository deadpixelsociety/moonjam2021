extends State
class_name SingleShotShoot

export(float) var cooldown = 1.0
export(NodePath) onready var animation_player = get_node(animation_player) as AnimationPlayer
export(NodePath) onready var enemy_trigger = get_node(enemy_trigger) as Area2D

var _last_fire = -1
var _shoot_delay = 0.2 + randf() * 0.4


func enter():
	if enemy_trigger.is_connected("body_entered", self, "_on_EnemyTrigger_body_entered"):
		enemy_trigger.disconnect("body_entered", self, "_on_EnemyTrigger_body_entered")
	if enemy_trigger.is_connected("body_exited", self, "_on_EnemyTrigger_body_exited"):
		enemy_trigger.disconnect("body_exited", self, "_on_EnemyTrigger_body_exited")
		
	enemy_trigger.connect("body_entered", self, "_on_EnemyTrigger_body_entered")
	enemy_trigger.connect("body_exited", self, "_on_EnemyTrigger_body_exited")
	_shoot()


func exit():
	enemy_trigger.disconnect("body_entered", self, "_on_EnemyTrigger_body_entered")
	enemy_trigger.disconnect("body_exited", self, "_on_EnemyTrigger_body_exited")


func execute(delta: float):
	_scan()
	_shoot()


func _scan():
	var drone = owner as Drone
	if drone and not drone.target:
		var bodies = enemy_trigger.get_overlapping_bodies()
		for _body in bodies:
			var body = _body as Node2D
			if body:
				drone.track_target(body)
				drone.reacquire()
		
		if not drone.target:
			_finish()


func _shoot():
	var drone = owner as Drone
	if not drone:
		return
		
	var gremlin = drone.target as Gremlin
	if not gremlin or gremlin.dead:
		return

	var dir = (drone.global_position - gremlin.global_position).normalized()
	drone.rotation = dir.angle()

	var now = OS.get_ticks_msec()
	var diff = now - _last_fire
	var cd = (cooldown + _shoot_delay) * 1000.0
	if _last_fire == -1 or diff >= cd:
		_last_fire = now
		animation_player.play("shoot")
		if animation_player:
			yield(animation_player, "animation_finished")


func _show_lazer():
	var drone = owner as Drone
	if not drone:
		return
	
	var gremlin = drone.target as Gremlin
	if not gremlin or gremlin.dead:
		return
		
	var line = Line2D.new()
	line.width = 2.0
	line.default_color = Color.red
	line.add_point(drone.global_position)
	line.add_point(gremlin.global_position)
	
	add_child(line)
	
	if gremlin:
		gremlin.hurt(1.3)
		if gremlin.dead:
			drone.reacquire()
		
	while line.points.size() > 0:
		var tree = get_tree()
		if tree:
			var timer = tree.create_timer(0.1)
			if timer:
				yield(timer, "timeout")
		line.remove_point(0)

	remove_child(line)


func _on_EnemyTrigger_body_entered(body):
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


func _on_EnemyTrigger_body_exited(body):
	if not body is Gremlin:
		return
	
	var drone = owner as Drone
	if not drone:
		return

	var target = body as Node2D
	if not target:
		return
		
	drone.forget_target(target)
	drone.reacquire()
	if not drone.target:
		_finish()
