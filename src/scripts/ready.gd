extends Control

var tiempoMax = 2
var tiempoActual = 0

func _ready():
	set_process(true)

func _process(delta):
	tiempoActual += 1 * delta
	if tiempoActual > tiempoMax:
		get_tree().change_scene("res://src/niveles/nivel_1.tscn")