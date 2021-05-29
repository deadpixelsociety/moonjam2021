extends PlayerActionState
class_name PlayerShootState

export(float) var bullet_cooldown = 0.80
export(PackedScene) var Bullet
export(NodePath) onready var shoot_origin = get_node(shoot_origin) as Node2D
export(NodePath) onready var revolver = get_node(revolver) as Sprite

var _last_fire = -1


func execute(delta: float):
	.execute(delta)

	if shoot_axis.length_squared() > 0.0:
		if player.heading.x < 0.0:
			shoot_origin.position = Vector2(-6.0, -1.0)
		else:			
			shoot_origin.position = Vector2(6.0, -1.0)
	
	if shoot_axis.length_squared() > 0.0:
		_shoot()
		
	_finish()


func _shoot():
	var now = OS.get_ticks_msec()
	var diff = now - _last_fire
	var cooldown_msec = bullet_cooldown * 1000.0
	if _last_fire == -1 or diff >= cooldown_msec:
		_last_fire = now
		var bullet = Bullet.instance() as Bullet
		bullet.global_position = shoot_origin.global_position

		if player.heading.x < 0.0:
			revolver.rotation = PI + player.heading.angle()
		else:
			revolver.rotation = player.heading.angle()

		bullet.fire(shoot_axis)
		if player and player.owner:
			player.owner.add_child(bullet)
