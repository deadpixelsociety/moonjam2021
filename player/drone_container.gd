extends Node2D
class_name DroneContainer

export(float) var spin_speed = 0.001
export(bool) var spinning = true


func _process(delta):	
#	if spinning:
#		rotation += spin_speed
#		rotation = fmod(rotation, PI * 2.0)
	pass


func get_free_attachment() -> DroneAttachment:
	var attachments = []
	for child in get_children():
		if child is DroneAttachment:
			if child.get_attached_drone() == null:
				attachments.push_back(child)

	if attachments.size() == 0:
		return null
						
	return attachments[randi() % attachments.size()] as DroneAttachment
