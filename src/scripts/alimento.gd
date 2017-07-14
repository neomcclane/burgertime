extends Node2D

const GRAVEDAD = 28.9 

export var hambArriba = true
export var hambAbajo = false

onready var eje = get_node("eje")
onready var ray = get_node("ray")

var bajar = false
var puedeBajar = true

func _ready():
	add_to_group("alimento")
	set_z(99)
	ray.add_exception(self)
	inicializar()
	set_process(true)
	set_fixed_process(true)
	
func inicializar():
	var l = [-12, -4, 4, 12]
	for n in range(4):
		var obj = preload("res://src/escenas/elemento.tscn").instance()
		if not hambAbajo:
			obj.posX = 8 * n
			obj.posY = 0
		else:
			obj.posX = 32 +(8 * n)
			obj.posY = 5
		obj.set_pos(Vector2(eje.get_pos().x+l[n], eje.get_pos().y))
		add_child(obj)

func _fixed_process(delta):
	if not bajar and ray.is_colliding():
		if ray.get_collider().is_in_group("alimento"):
			bajar = true
			for elemento in get_children():
				if elemento.is_in_group("elemento"):
					elemento.set_pos(Vector2(elemento.get_pos().x, elemento.get_pos().y+1))

func _process(delta):
	if puedeBajar:
		var bandera = true
		for elemento in get_children():
			if elemento.is_in_group("elemento") and not elemento.abajo:
				bandera = false
		if bandera:
			bajar = true
			
		if bajar:
			var velY = get_global_pos().y+(GRAVEDAD * sqrt(delta))/2
			set_global_pos(Vector2(get_global_pos().x, velY))
	
func _draw():
	var diff = 15
	draw_line(Vector2(eje.get_pos().x-diff, eje.get_pos().y), Vector2(eje.get_pos().x+diff, eje.get_pos().y), Color(255, 0, 0, 255))
	draw_line(Vector2(eje.get_pos().x, eje.get_pos().y-diff), Vector2(eje.get_pos().x, eje.get_pos().y+diff), Color(0, 255, 0, 255))

func _on_alimento_body_enter( body ):
	if bajar and body.get_name() == "mapa":
		bajar = false
		for elemento in get_children():
			if elemento.is_in_group("elemento"):
				elemento.set_pos(Vector2(elemento.get_pos().x, elemento.get_pos().y-1))
				elemento.abajo = false


func _on_alimento_area_enter( area ):
	if bajar and area.is_in_group("paleta"):
		bajar = false
		puedeBajar = false
		for elemento in get_children():
			if elemento.is_in_group("elemento"):
				elemento.set_pos(Vector2(elemento.get_pos().x, elemento.get_pos().y-1))
				elemento.abajo = false
	
	if bajar and area.is_in_group("alimento") and not area.puedeBajar:
		bajar = false
		puedeBajar = false
		for elemento in get_children():
			if elemento.is_in_group("elemento"):
				elemento.set_pos(Vector2(elemento.get_pos().x, elemento.get_pos().y-2))
				elemento.abajo = false