extends Sprite
class_name BloodPrinter

signal print_finished

enum Drones {SINGLE_SHOT}

export(Drones) var selected_drone := Drones.SINGLE_SHOT
export(NodePath) onready var drone_container = get_node(drone_container) as Node2D

var _drone_map = {
	Drones.SINGLE_SHOT : load("res://player/drones/single_shot_drone.tscn"),
}

onready var _animation_player := $AnimationPlayer
onready var _drone_spawn := $DroneSpawn


func print_drone():
	_animation_player.play("print")
	yield(_animation_player, "animation_finished")
	emit_signal("print_finished")


func spawn_drone():
	if not drone_container:
		return
		
	var _drone = _drone_map.get(selected_drone, null) as PackedScene
	if not _drone:
		return
	
	var drone = _drone.instance() as Drone
	if not drone:
		return
	
	drone_container.add_child(drone)
	drone.global_position = _drone_spawn.global_position
	drone.spawn()
