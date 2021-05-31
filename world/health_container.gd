extends HBoxContainer
class_name HealthContainer

onready var _heart_tex = load("res://assets/sprites/heart.png")


func _ready():
	GameEvents.connect("health_changed", self, "_on_health_changed")


func _on_health_changed(health: int):
	for _child in get_children():
		var child = _child as Control
		child.queue_free()
	
	for i in range(health):
		var heart = TextureRect.new()
		heart.texture = _heart_tex
		add_child(heart)
