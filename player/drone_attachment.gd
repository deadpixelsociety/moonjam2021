extends Node2D
class_name DroneAttachment

signal attachment_completed

var attached = false


func get_attached_drone() -> Drone:
	if get_child_count() == 0:
		return null
		
	return get_child(0) as Drone


func attach_drone(drone: Drone):
	var container = get_parent()
	if container:
		container.spinning = false
	
	attached = true
	drone.attach_out()
	yield(drone, "attach_out_finished")
	drone.get_parent().remove_child(drone)
	add_child(drone)
	drone.attach_in()
	yield(drone, "attach_in_finished")
	emit_signal("attachment_completed")

	if container:
		container.spinning = true


func detach_drone():
	var drone = get_attached_drone()
	if not drone:
		return
		
	attached = false
	remove_child(drone)
