extends Node

signal level_changed

var current_level = 1 setget _set_level, _get_level


func _set_level(value: int):
	current_level = value
	emit_signal("level_changed", current_level)


func _get_level() -> int:
	return current_level
