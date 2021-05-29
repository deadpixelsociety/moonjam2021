extends Node
class_name State

signal state_finished
signal state_requested

enum ProcessingMode {IDLE, PHYSICS}

export(String) var state_name = ""
export(ProcessingMode) var processing_mode = ProcessingMode.IDLE


func execute(delta: float):
	pass


func handle_input(delta: float):
	pass


func enter():
	pass


func exit():
	pass


func set_data(data):
	pass


func _finish(new_state: String = ""):
	emit_signal("state_finished", new_state)


func _request_state(state: String):
	emit_signal("state_requested", state)
