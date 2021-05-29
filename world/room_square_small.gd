extends Node2D
class_name RoomSquareSmall

onready var _player := $Player
onready var _navigation := $Navigation2D
onready var _line := $Line2D


func _input(event):
	if not event is InputEventMouseButton:
		return
		
	if event.button_index != BUTTON_RIGHT or not event.pressed:
		return
	
	var path = _navigation.get_simple_path(
		_player.global_position, 
		get_global_mouse_position()
	)
	
	_line.points = path
	_player.path = path


func _ready():
	pass
