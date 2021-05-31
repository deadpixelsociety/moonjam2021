extends Sprite
class_name BloodPrinter

signal print_finished

enum Drones {SINGLE_SHOT, AUTO_SHOT, GRENADE, SHOTGUN}

export(Drones) var selected_drone := Drones.SINGLE_SHOT
export(NodePath) onready var drone_container = get_node(drone_container) as DroneContainer

var _drone_map = {
	Drones.SINGLE_SHOT : load("res://player/drones/single_shot_drone.tscn"),
	Drones.AUTO_SHOT : load("res://player/drones/auto_shot_drone.tscn"),
	Drones.GRENADE : load("res://player/drones/grenade_drone.tscn"),
	Drones.SHOTGUN : load("res://player/drones/shotgun_drone.tscn"),
}

onready var _animation_player := $AnimationPlayer
onready var _drone_spawn := $DroneSpawn


func print_drone():
	_animation_player.play("print")
	yield(_animation_player, "animation_finished")
	emit_signal("print_finished")


func spawn_drone():
	var player = owner as Player
	if not player:
		return
	
	if not player.can_attach_drone():
		return
		
	if not drone_container:
		return
	
	var attachment = drone_container.get_free_attachment()
	if not attachment:
		return
		
	var _drone = _drone_map.get(selected_drone, null) as PackedScene
	if not _drone:
		return
	
	var drone = _drone.instance() as Drone
	if not drone:
		return
	
	drone.visible = false
	_drone_spawn.add_child(drone)
	drone.spawn()
	yield(drone, "drone_spawned")
	attachment.attach_drone(drone)
	yield(attachment, "attachment_completed")
