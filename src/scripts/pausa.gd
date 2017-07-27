extends Node2D

onready var label = get_node("Control/label")
onready var panel = get_node("Control/panel")
onready var camara = null

func _ready():
	set_z(200)
	panel.set_pos(Vector2(-97, 0))
	panel.set_size(Vector2(1538, 1312))
	camara = get_owner().get_node("camara")
	label.set_pos(Vector2(camara.get_camera_screen_center().x-125, camara.get_camera_screen_center().y))
	self.hide()
	set_process(true)
	
func _process(delta):
	if global.EN_PAUSA and not self.is_visible():
		self.show()
	elif not global.EN_PAUSA and self.is_visible():
		self.hide()
		