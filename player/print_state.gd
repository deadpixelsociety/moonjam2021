extends State
class_name PrintState

export(NodePath) onready var animated_sprite = get_node(animated_sprite) as AnimatedSprite
export(NodePath) onready var blood_printer = get_node(blood_printer) as BloodPrinter

var drone_selection = 0


func enter():
	blood_printer.connect("print_finished", self, "_on_print_finished")


func execute(delta: float):
	var player = owner as Player
	if not player:
		return
	
	blood_printer.selected_drone = player.requested_drone
	blood_printer.print_drone()


func exit():
	blood_printer.disconnect("print_finished", self, "_on_print_finished")


func _on_print_finished():
	_finish()
