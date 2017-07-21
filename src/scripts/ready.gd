extends Control

onready var player = get_node("Panel/player")
onready var ready = get_node("Panel/ready")

var tiempoMax = 2
var tiempoActual = 0

func _ready():
	set_process(true)
	if global.GAME_OVER:
		player.set_text("Game Over")
		player.set_pos(Vector2(player.get_pos().x, player.get_pos().y+50))
		ready.hide()

func _process(delta):
	tiempoActual += 1 * delta
	if tiempoActual > tiempoMax:
		if not global.GAME_OVER:
			get_tree().change_scene("res://src/niveles/nivel_1.tscn")
		else:
			funcionesGlobales.reiniciarVariables()
			get_tree().change_scene("res://src/niveles/main.tscn")