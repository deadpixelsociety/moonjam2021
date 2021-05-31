extends Label
class_name LevelCounter

func _process(delta):
	text = "LEVEL %d/4" % LevelManager.current_level
