extends Node

var expr = RegEx.new()
var s = ""
var ex = ""
var en_pause = false

func _ready():
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)
	ex = "^(nivel_[0-9]+.[a-z]+)$"
	expr.compile(ex)
	
func _input(event):
	if event.type == InputEvent.KEY:
		if event.scancode == KEY_P and event.pressed and not en_pause and expr.find(global.ESCENA_ACTUAL) == 0:
			en_pause = true
			if get_tree().is_paused():
				get_tree().set_pause(false)
				global.EN_PAUSA = false
			else:
				get_tree().set_pause(true)
				global.EN_PAUSA = true
				
		elif event.scancode == KEY_P and not event.pressed and en_pause:
			en_pause = false
		
		elif not global.EN_PAUSA_SALIR and event.scancode == KEY_ESCAPE and event.pressed and not get_tree().is_paused() and expr.find(global.ESCENA_ACTUAL) == 0:
#			get_tree().change_scene("res://src/niveles/exit.tscn")
			get_tree().set_pause(true)
			global.EN_PAUSA_SALIR = true
		
		elif global.EN_PAUSA and event.scancode == KEY_ESCAPE and event.pressed and get_tree().is_paused() and expr.find(global.ESCENA_ACTUAL) == 0:
			get_tree().set_pause(false)
			global.EN_PAUSA = false
			
func reiniciarVariables():
	global.NUM_VIDA = global.SAL_NUM_VIDA
	global.NUM_PIMIENTA = global.SAL_NUM_PIMIENTA
	global.GAME_OVER = false

func  inicializarJuego():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)