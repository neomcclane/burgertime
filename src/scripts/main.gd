extends Node

onready var start = get_node("Control/Panel/start")
onready var instruction = get_node("Control/Panel/instruction")
onready var exit = get_node("Control/Panel/exit")
onready var iconRight = get_node("Control/Panel/right")
onready var iconLeft = get_node("Control/Panel/left")
onready var sound = get_node("sonidos")

var opciones = {"start":true, "instruction": false, "exit":false}
var diff = 4

func _ready():
	global.ESCENA_ACTUAL = "main.tscn"
	print("Escena actual: "+global.ESCENA_ACTUAL)
	if global.MENU_OPCION == "start":
		global.ESCENA_ACTUAL = "nivel_1.tscn"
		opciones = {"start":true, "instruction": false, "exit":false}
		iconLeft.set_pos(Vector2(iconLeft.get_pos().x, start.get_pos().y+diff))
		iconRight.set_pos(Vector2(iconRight.get_pos().x, start.get_pos().y+diff))
	elif global.MENU_OPCION == "instruction":
		opciones = {"start":false, "instruction": true, "exit":false}
		iconLeft.set_pos(Vector2(iconLeft.get_pos().x, instruction.get_pos().y+diff))
		iconRight.set_pos(Vector2(iconRight.get_pos().x, instruction.get_pos().y+diff))
	set_process_input(true)
	
	
func _input(event):
	if event.type == InputEvent.KEY:
		if event.scancode == KEY_UP and event.pressed:
			sound.play("seleccion_1")
			if opciones["start"]:
				opciones = {"start":false, "instruction": false, "exit":true}
			elif opciones["instruction"]:
				opciones = {"start":true, "instruction": false, "exit":false}
			elif opciones["exit"]:
				opciones = {"start":false, "instruction": true, "exit":false}
				
		elif event.scancode == KEY_DOWN and event.pressed:
			sound.play("seleccion_1")
			if opciones["start"]:
				opciones = {"start":false, "instruction": true, "exit":false}
			elif opciones["instruction"]:
				opciones = {"start":false, "instruction": false, "exit":true}
			elif opciones["exit"]:
				opciones = {"start":true, "instruction": false, "exit":false}
		
		elif event.scancode == KEY_RETURN and event.pressed:
			if opciones["start"]:
#				get_tree().change_scene("res://src/niveles/intermedio.tscn")
				global.MENU_OPCION = "start"
				get_tree().change_scene("res://src/niveles/ready.tscn")
			elif opciones["instruction"]:
				global.MENU_OPCION = "instruction"
				get_tree().change_scene("res://src/niveles/instrucciones.tscn")
			elif opciones["exit"]:
				get_tree().quit()
		
		if opciones["start"]:
			iconLeft.set_pos(Vector2(iconLeft.get_pos().x, start.get_pos().y+diff))
			iconRight.set_pos(Vector2(iconRight.get_pos().x, start.get_pos().y+diff))
		elif opciones["instruction"]:
			iconLeft.set_pos(Vector2(iconLeft.get_pos().x, instruction.get_pos().y+diff))
			iconRight.set_pos(Vector2(iconRight.get_pos().x, instruction.get_pos().y+diff))
		elif opciones["exit"]:
			iconLeft.set_pos(Vector2(iconLeft.get_pos().x, exit.get_pos().y+diff))
			iconRight.set_pos(Vector2(iconRight.get_pos().x, exit.get_pos().y+diff))
		
