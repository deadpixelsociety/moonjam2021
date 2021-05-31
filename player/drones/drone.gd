extends Area2D
class_name Drone

signal drone_spawned
signal attach_in_finished
signal attach_out_finished

var target: Node2D = null

var _targets = []


func _process(delta):
	reacquire()


func spawn():
	emit_signal("drone_spawned")


func attach_in():
	emit_signal("attach_in_finished")


func attach_out():
	emit_signal("attach_out_finished")


func track_target(new_target: Node2D):
	if not _targets.has(new_target):
		_targets.push_back(new_target)
		var gremlin = new_target as Gremlin
		if gremlin:
			gremlin.connect("died", self, "_target_died")


func forget_target(old_target: Node2D):
	_targets.erase(old_target)
	var gremlin = old_target as Gremlin
	if gremlin:
		if gremlin.is_connected("died", self, "_target_died"):
			gremlin.disconnect("died", self, "_target_died")


func reacquire():
	target = null
	
	if _targets.size() == 0:
		return
	
	for _target in _targets:
		var new_target = _target as Node2D
		closest_target(new_target)


func closest_target(new_target: Node2D):
	var last_target = target
	if not target or not new_target:
		target = new_target
	else:
		var dist = global_position.distance_squared_to(target.global_position)
		var new_dist = global_position.distance_squared_to(new_target.global_position)
		if new_dist < dist:
			target = new_target	


func _target_died(dead_target):
	if dead_target is Gremlin:
		forget_target(dead_target)
	
	reacquire()

