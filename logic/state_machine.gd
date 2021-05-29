extends Node
class_name StateMachine

signal state_finished

export(NodePath) onready var default_state = get_node(default_state) as State

var _state_map = {}
var _state_stack = []


func _ready():
	_state_map.clear()
	_state_stack.clear()
	
	for child in get_children():
		if child is State:
			_state_map[child.state_name] = child
			child.connect("state_finished", self, "_on_state_finished")
			child.connect("state_requested", self, "_on_state_requested")

	if default_state:
		default_state.enter()
		_state_stack.push_back(default_state)


func _physics_process(delta):
	var current_state = get_current_state()
	if not current_state:
		return
			
	if current_state.processing_mode == State.ProcessingMode.PHYSICS:
		_process_state(delta, current_state)


func _process(delta):
	var current_state = get_current_state()
	if not current_state:
		return
			
	if current_state.processing_mode == State.ProcessingMode.IDLE:
		_process_state(delta, current_state)


func _process_state(delta: float, state: State):
	state.handle_input(delta)
	state.execute(delta)


func get_current_state() -> State:
	return _state_stack.back()


func get_state(name: String) -> State:
	return _state_map.get(name, null) as State


func has_state(name: String):
	return _state_map.has(name)


func _on_state_finished(new_state: String):
	var current_state = get_current_state() as State
	if current_state:
		current_state.exit()
		_state_stack.erase(current_state)
		
	current_state = get_state(new_state) as State
	if not current_state:
		current_state = get_current_state()
		if not current_state:
			current_state = default_state
	
	if current_state:
		current_state.enter()
		_state_stack.push_back(current_state)


func _on_state_requested(name: String):
	var state = get_state(name) as State
	if not state:
		return
	
	state.enter()
	_state_stack.push_back(state)
