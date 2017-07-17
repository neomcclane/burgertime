extends Node2D

onready var pimienta = get_node("Control/panelArriba/pimienta/numero")
onready var vida = get_node("Control/panelArriba/vida/numero")
onready var panelAbajo = get_node("Control/panelAbajo")

var numPimienta = global.NUM_PIMIENTA

func _ready():
	pimienta.set_text(str(numPimienta))
	vida.set_text(str(global.NUM_VIDA))
	set_process(true)
	
func _process(delta):
	if numPimienta != global.NUM_PIMIENTA:
		pimienta.set_text(str(global.NUM_PIMIENTA))
		numPimienta = global.NUM_PIMIENTA