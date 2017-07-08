extends Node2D

onready var sound = get_node("sonidos")
onready var yes = get_node("Control/Panel/yes")
onready var no = get_node("Control/Panel/no")

var opciones = {"yes":false, "no":true}

func _ready():
	yes.add_color_override("font_color", Color(1, 1, 1, 1))
	no.add_color_override("font_color", Color(1, 0.2, 0.2, 1))
	set_z(150)
	set_process_input(true)
	set_process(true)
	
	
func _process(delta):
	if global.EN_PAUSA_SALIR:
		show()
	else:
		hide()

func _input(event):
	if global.EN_PAUSA_SALIR and event.type == InputEvent.KEY:
		if event.scancode == KEY_LEFT and event.pressed:
			sound.play("seleccion_1")
			if opciones["yes"]:
				opciones = {"yes":false, "no":true}
				yes.add_color_override("font_color", Color(1, 1, 1, 1))
				no.add_color_override("font_color", Color(1, 0.2, 0.2, 1))
			elif opciones["no"]:
				opciones = {"yes":true, "no":false}
				yes.add_color_override("font_color", Color(1, 0.2, 0.2, 1))
				no.add_color_override("font_color", Color(1, 1, 1, 1))
			
		elif event.scancode == KEY_RIGHT and event.pressed:
			sound.play("seleccion_1")
			if opciones["yes"]:
				opciones = {"yes":false, "no":true}
				yes.add_color_override("font_color", Color(1, 1, 1, 1))
				no.add_color_override("font_color", Color(1, 0.2, 0.2, 1))
			elif opciones["no"]:
				opciones = {"yes":true, "no":false}
				yes.add_color_override("font_color", Color(1, 0.2, 0.2, 1))
				no.add_color_override("font_color", Color(1, 1, 1, 1))
		
		elif event.scancode == KEY_RETURN and event.pressed:
			if opciones["yes"]:
				if get_tree().is_paused():
					get_tree().set_pause(false)
				global.EN_PAUSA_SALIR = false
				get_tree().change_scene("res://src/niveles/main.tscn")
			elif opciones["no"]:
				global.EN_PAUSA_SALIR = false
				get_tree().set_pause(false)