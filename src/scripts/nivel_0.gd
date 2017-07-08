extends Node2D

export var grid = false

var expr = RegEx.new()

func _ready():
	global.ESCENA_ACTUAL = "nivel_0.tscn"
	print("Escena actual: "+global.ESCENA_ACTUAL)
	print("*****************")
	print(get_tree().get_nodes_in_group("escaleras"))
	print("*****************")
	var texto = "abmundo"
	expr.compile("^([a-z]+\\s?[a-z]+)$")
	var i = expr.find(texto)
	
	print("i: "+str(i))
	
	var s = expr.get_capture(i)
	print("s: "+s)
	
func _draw():
	if grid:
		draw_line(Vector2(0, 0), Vector2(0, 250), Color(255, 10, 10, 255), 2)
		draw_line(Vector2(0, 0), Vector2(250, 0), Color(1, 0.1, 0.1, 1), 2)
