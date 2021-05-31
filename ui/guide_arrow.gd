extends TextureRect
class_name GuideArrow


func _ready():
	if GameEvents.is_connected("guide_arrow_updated", self, "_on_update"):
		GameEvents.disconnect("guide_arrow_updated", self, "_on_update")
	GameEvents.connect("guide_arrow_updated", self, "_on_update")
	

func _on_update(dir: Vector2):
	visible = true
	rect_rotation = rad2deg(dir.angle())
