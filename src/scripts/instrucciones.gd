extends Node

func _ready():
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.KEY:
		if event.scancode == KEY_ESCAPE and event.pressed:
			global.ESCENA_ACTUAL = "main.tscn"
			get_tree().change_scene("res://src/niveles/main.tscn")
	