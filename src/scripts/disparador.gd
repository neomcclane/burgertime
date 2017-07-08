extends Area2D

onready var shape = get_node("shape")
export var arriba = true
export var dibujar = true
var color = null
var rojo = Color(255, 0, 0)
var azul = Color(0, 0, 255)

func _ready():
	if arriba:
		color = rojo
	else:
		color = azul
		
	shape.set_pos(Vector2(0,0))
	shape.get_shape().set_extents(Vector2(32, 5))
	shape.set_pos(Vector2(32, 2))

func _draw():
	if dibujar:
		draw_rect(Rect2(Vector2(0, 0), Vector2(64, 5)), color)