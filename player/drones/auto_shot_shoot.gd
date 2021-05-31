extends State
class_name AutoShotShoot

export(PackedScene) var Bullet
export(NodePath) onready var animation_player = get_node(animation_player) as AnimationPlayer
export(NodePath) onready var enemy_trigger = get_node(enemy_trigger) as Area2D
export(NodePath) onready var bullet_spawns = get_node(bullet_spawns) as Node2D
export(NodePath) onready var sfx = get_node(sfx) as AudioStreamPlayer

var _bullet_origin = Vector2.ZERO
var _fire_dir = Vector2.ZERO


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
		var bodies = enemy_trigger.get_overlapping_areas()
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

	_fire_dir = (drone.global_position - gremlin.global_position).normalized()
	drone.rotation = _fire_dir.angle()

	_bullet_origin = drone.global_position
	if bullet_spawns and bullet_spawns.get_child_count() > 0:
		var child = bullet_spawns.get_child(randi() % bullet_spawns.get_child_count())
		var node2d = child as Node2D
		if node2d:
			_bullet_origin = node2d.global_position

	animation_player.play("shoot")
	yield(animation_player, "animation_finished")


func _shoot_bullet():
	var drone = owner as Drone
	if not drone:
		return
	
	var bullet = Bullet.instance() as Bullet
	bullet.global_position = _bullet_origin

	if sfx and not sfx.playing:
		sfx.play()
	
	bullet.fire(_fire_dir * -1)
	
	var entities = get_tree().root.find_node("Entities", true, false) as YSort
	if entities:
		entities.call_deferred("add_child", bullet)


func _on_EnemyTrigger_body_entered(body):
	print("shoot, enter triggered")
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
	print("shoot, exit triggered")	
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
