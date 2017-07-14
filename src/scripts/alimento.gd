extends Node2D

onready var eje = get_node("eje")

var bajar = false

func _ready():
	set_z(99)
	inicializar()
	set_process(true)
	
func inicializar():
	var l = [-12, -4, 4, 12]
	for n in range(4):
		var obj = preload("res://src/escenas/elemento.tscn").instance()
		obj.posX = 8 * n
		obj.set_pos(Vector2(eje.get_pos().x+l[n], eje.get_pos().y))
		add_child(obj)

func _process(delta):
	var bandera = true
	for elemento in get_children():
		if elemento.is_in_group("elemento") and not elemento.abajo:
			bandera = false
	if bandera:
		bajar = true
	if bajar:
		var velY = get_global_pos().y+(18.8 * sqrt(delta))/2
		set_global_pos(Vector2(get_global_pos().x, velY))
	
func _draw():
	var diff = 15
	draw_line(Vector2(eje.get_pos().x-diff, eje.get_pos().y), Vector2(eje.get_pos().x+diff, eje.get_pos().y), Color(255, 0, 0, 255))
	draw_line(Vector2(eje.get_pos().x, eje.get_pos().y-diff), Vector2(eje.get_pos().x, eje.get_pos().y+diff), Color(0, 255, 0, 255))

func _on_alimento_body_enter( body ):
	if bajar and body.get_name() == "mapa":
		print("colisiono!")
		bajar = false
		for elemento in get_children():
			if elemento.is_in_group("elemento"):
				elemento.set_pos(Vector2(elemento.get_pos().x, elemento.get_pos().y-1))
				elemento.abajo = false
