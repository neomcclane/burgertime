extends Node2D

onready var label = get_node("label")
onready var camara = get_node("../camara")

func _ready():
	set_z(200)
	var view = get_viewport_rect().size
	label.set_pos(Vector2(view.x/2+100,view.y))
	self.hide()
	set_process(true)
	
func _process(delta):
	if global.EN_PAUSA and not self.is_visible():
		self.show()
	elif not global.EN_PAUSA and self.is_visible():
		self.hide()
		