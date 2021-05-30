extends Area2D
class_name Drone

signal drone_spawned
signal attach_in_finished
signal attach_out_finished


func spawn():
	emit_signal("drone_spawned")


func attach_in():
	emit_signal("attach_in_finished")


func attach_out():
	emit_signal("attach_out_finished")
