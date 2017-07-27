extends Node2D

var GRAVEDAD = global.VELOCIDAD_CAIDA

export var hambArriba = true
export var hambAbajo = false
export var lechuga = false
export var carne = false

onready var eje = get_node("eje")

var bajar = false
var puedeBajar = true
var globalDiff = 1
var globalDiffMayor = 2

var contadorCaida = 0
var tiempoEsperaCaida = 0
var tiempoEsperaCaidaMax = 0.4
var banderaContadorCaida = false

var banderaCaidaContinua = false

func _ready():
	add_to_group("alimento")
	set_z(99)
	inicializar()
	set_process(true)
	
func inicializar():
	var l = [-12, -4, 4, 12]
	for n in range(4):
		var obj = preload("res://src/escenas/elemento.tscn").instance()
		if hambArriba:
			obj.posX = 8 * n
			obj.posY = 0
		elif hambAbajo:
			obj.posX = 32 +(8 * n)
			obj.posY = 5
		elif carne:
			obj.posX = 64 +(8 * n)
			obj.posY = 5
		elif lechuga:
			obj.posX = 96 +(8 * n)
			obj.posY = 5
		
		obj.set_pos(Vector2(eje.get_pos().x+l[n], eje.get_pos().y))
		add_child(obj)

func _process(delta):
	if puedeBajar:
		var bandera = true
		for elemento in get_children():
			if elemento.is_in_group("elemento") and not elemento.abajo:
				bandera = false
		if not bajar and bandera:
			bajar = true
			banderaCaidaContinua = true
			for elemento in get_children():
				if elemento.is_in_group("elemento"):
					if lechuga or carne:
						elemento.set_pos(Vector2(elemento.get_pos().x, eje.get_pos().y+globalDiffMayor))
					else:
						elemento.set_pos(Vector2(elemento.get_pos().x, eje.get_pos().y+globalDiff))
					
		if bajar:
			if get_z() == 99:
				set_z(107)
				
			var velY = get_global_pos().y+(GRAVEDAD * sqrt(delta))/2
			set_global_pos(Vector2(get_global_pos().x, velY))
		
		elif not bajar and get_z() == 107:
				set_z(99)

	if banderaContadorCaida and tiempoEsperaCaida <= tiempoEsperaCaidaMax:
			tiempoEsperaCaida += 1 * delta
	
	elif banderaContadorCaida and tiempoEsperaCaida > tiempoEsperaCaidaMax:
		contadorCaida = 0
		banderaContadorCaida = false
		bajar = true
		banderaCaidaContinua = true

func _draw():
	pass
	# var diff = 150
	# draw_line(Vector2(eje.get_pos().x-diff, eje.get_pos().y), Vector2(eje.get_pos().x+diff, eje.get_pos().y), Color(255, 0, 0, 255))
	# draw_line(Vector2(eje.get_pos().x, eje.get_pos().y-diff), Vector2(eje.get_pos().x, eje.get_pos().y+diff), Color(0, 255, 0, 255))

func _on_alimento_body_enter( body ):
	if bajar and body.get_name() == "mapa" and contadorCaida==0:
		bajar = false
		banderaCaidaContinua = false
		for elemento in get_children():
			if elemento.is_in_group("elemento"):
				elemento.set_pos(Vector2(elemento.get_pos().x, elemento.get_pos().y-1))
				elemento.abajo = false
	
	elif bajar and body.get_name() == "mapa" and contadorCaida==1:
		# contadorCaida -= 1
		banderaContadorCaida = true
		bajar = false
		for elemento in get_children():
			if elemento.is_in_group("elemento"):
				elemento.set_pos(Vector2(elemento.get_pos().x, elemento.get_pos().y-1))
				elemento.abajo = false
		# puedeBajar = false

func _on_alimento_area_enter( area ):
	if area.is_in_group("alimento") and area.get_global_pos().y < self.get_global_pos().y:
		bajar = true
		banderaCaidaContinua = true
		if area.contadorCaida > 0:
			area.bajar = false

		for elemento in get_children():
			if elemento.is_in_group("elemento"):
				if lechuga or carne:
					elemento.set_pos(Vector2(elemento.get_pos().x, eje.get_pos().y+globalDiffMayor))
				else:
					elemento.set_pos(Vector2(elemento.get_pos().x, eje.get_pos().y+globalDiff))

	if bajar and area.is_in_group("paleta"):
		bajar = false
		banderaCaidaContinua = false
		puedeBajar = false
		for elemento in get_children():
			if elemento.is_in_group("elemento"):
				elemento.set_pos(Vector2(elemento.get_pos().x, elemento.get_pos().y-1))
				elemento.abajo = false
				elemento.set_pos(Vector2(elemento.get_pos().x, eje.get_pos().y))
	
	if (bajar or contadorCaida==1) and area.is_in_group("alimento") and not area.puedeBajar:
		bajar = false
		banderaCaidaContinua = false
		puedeBajar = false
		for elemento in get_children():
			if elemento.is_in_group("elemento"):
				elemento.set_pos(Vector2(elemento.get_pos().x, elemento.get_pos().y-2))
				elemento.abajo = false
				if lechuga or carne:
					elemento.set_pos(Vector2(elemento.get_pos().x, eje.get_pos().y+globalDiffMayor))
				else:
					elemento.set_pos(Vector2(elemento.get_pos().x, eje.get_pos().y+globalDiff))