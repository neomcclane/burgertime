extends Area2D

onready var sprite = get_node("sprite")
onready var eje = get_node("eje")
onready var rayIzq = get_node("rayIzq")
onready var rayDer = get_node("rayIzq")

var VELOCIDAD = 150

var escaleras = {}
var chef = null
var enEscena = false
var pisoActual = 0
var posX = 0
var posY = 0
var sobreEscaleras = false
var matrizNivel = []
var FILAS = 8
var COLUMNAS = 17
var posInicial = []
var posFinal = []
var camino = []

var buscando = false

func inicializarEscaleras():
	if get_parent().get_node("escaleras") != null:
		enEscena = true
		chef = get_parent().get_node("chef")
		var nodoEscaleras = get_parent().get_node("escaleras")
		for nodo in nodoEscaleras.get_children():
			var clave = int(nodo.get_name())
			escaleras[clave] = []
			for escalera in nodo.get_children():
				escaleras[clave].append(escalera)

func crearMatrizNivel1():
	var vector = []
	for fila in range(FILAS):
		for columna in range(COLUMNAS):
			vector.append(Vector2(-2,-2))
		matrizNivel.append(vector)
		vector = []

func generarMatriz():
	var col = -1
	var colAux = -1
	var dibujado = false

	for pos in range(8):
		for escalera in escaleras[pos]:
			col = int(escalera.get_name())
			if not escalera.is_in_group("escaleras"):
				matrizNivel[pos][col] = Vector2(-1,-1)
			else:
				if escalera.filas == 4:
					matrizNivel[pos-1][col] = Vector2(escalera.posicion.get_global_pos().x, escalera.posicion.get_global_pos().y-(escalera.filas*escalera.ancho)) 
				elif escalera.filas == 8:
					matrizNivel[pos-1][col] = Vector2(-3,-3)
					matrizNivel[pos-2][col] = Vector2(escalera.posicion.get_global_pos().x, escalera.posicion.get_global_pos().y-(escalera.filas*escalera.ancho)) 
				elif escalera.filas == 12:
					matrizNivel[pos-1][col] = Vector2(-3,-3)
					matrizNivel[pos-2][col] = Vector2(-3,-3)
					matrizNivel[pos-3][col] = Vector2(escalera.posicion.get_global_pos().x, escalera.posicion.get_global_pos().y-(escalera.filas*escalera.ancho)) 
				matrizNivel[pos][col] = escalera.posicion.get_global_pos()
			
			
	
	# for vector in matrizNivel:
	# 	print(vector)

func localizarPosicion(player):
	var posChef = player.eje.get_global_pos()
	var diff = 5
	var posAux = null
	var salida = false
	var v = []

	var p0 = null
	var p1 = null

	for fila in range(FILAS):
		for columna in range(COLUMNAS):
			if posAux != null and posAux.y == matrizNivel[fila][columna].y and matrizNivel[fila][columna].y+diff >= posChef.y and matrizNivel[fila][columna].x+32 >= posChef.x:
				v = [[p0, p1], [fila, columna]]
				salida = true	
				break
			elif matrizNivel[fila][columna].x != -1 and matrizNivel[fila][columna].x != -2:
				p0 = fila
				p1 = columna
				posAux = matrizNivel[fila][columna]

		if salida:
			break
		
	randomize()
	return v[randi()%2+0]


func existeElementoCamino(arreglo, elemento):
	for token in arreglo:
		if token.x == elemento.x and token.y == elemento.y:
			return true
	return false

func existeCerrado(posicion, arreglo):
	for elemento in arreglo:
		if elemento.x == posicion.x and elemento.y == posicion.y:
			return true
	return false

func generarCamino(posInicio, posFin, arreglo=[]):
	var h = 0
	var f = 0
	var pInicio = Vector2(posInicio[0], posInicio[1])
	var pFinal = Vector2(posFin[0], posFin[1])
	var pActual = pInicio
	var vAbierto = []
	var vCerrado = []
	var vCamino = []
	
	while pActual.x != pFinal.x or pActual.y != pFinal.y:
		vCerrado.append(Vector2(pActual.x, pActual.y))
		#izquierda
		if pActual.y > 0 and matrizNivel[pActual.x][pActual.y-1].x != -2 and not existeCerrado(Vector2(pActual.x, pActual.y-1), vCerrado):
			h = abs(pActual.x-pFinal.x)+abs((pActual.y-1)-pFinal.y) 
			f = h + 10 
			vAbierto.append([[pActual.x, pActual.y-1], f])
		#derecha
		if pActual.y < (COLUMNAS-1) and matrizNivel[pActual.x][pActual.y+1].x != -2 and not existeCerrado(Vector2(pActual.x, pActual.y+1), vCerrado):
			h = abs(pActual.x-pFinal.x)+abs((pActual.y+1)-pFinal.y) 
			f = h + 10
			vAbierto.append([[pActual.x, pActual.y+1], f])
		#arriba OJO
		if pActual.x > 0 and matrizNivel[pActual.x][pActual.y].x != -1 and matrizNivel[pActual.x-1][pActual.y].y != -2 and matrizNivel[pActual.x-1][pActual.y].y != -1 and not existeCerrado(Vector2(pActual.x-1, pActual.y), vCerrado):
			print("arribaaa: ")
			print(matrizNivel[pActual.x][pActual.y])
			h = abs((pActual.x-1)-pFinal.x)+abs(pActual.y-pFinal.y) 
			f = h + 10
			vAbierto.append([[pActual.x-1, pActual.y], f])
		#abajo OJO
		if pActual.x < (FILAS-1) and matrizNivel[pActual.x][pActual.y].x != -1 and matrizNivel[pActual.x+1][pActual.y].y != -2 and matrizNivel[pActual.x+1][pActual.y].y != -1 and not existeCerrado(Vector2(pActual.x+1, pActual.y), vCerrado):
			h = abs((pActual.x+1)-pFinal.x)+abs(pActual.y-pFinal.y) 
			f = h + 10
			vAbierto.append([[pActual.x+1, pActual.y], f])
		
		var c = 0
		var posEleminar = 0

		for i in range(vAbierto.size()):
			if i == 0:
				c = vAbierto[i][1]
				posEleminar = i
			else:
				if c > vAbierto[i][1]:
					c = vAbierto[i][1]
					posEleminar = i
		
		vCamino.append(Vector2(pActual.x, pActual.y))

		if vAbierto.size() > 0:
			pActual = Vector2(vAbierto[posEleminar][0][0], vAbierto[posEleminar][0][1])
			vAbierto.remove(posEleminar)
	
	vCamino.append(Vector2(pActual.x, pActual.y))

	return vCamino

func convertirPosicion(posicion):
	for i in range(matrizNivel.size()):
		for j in range(matrizNivel[i].size()):
			if posicion.x == matrizNivel[i][j].x and posicion.y == matrizNivel[i][j].y:
				return [i, j]
	return [-1, -1]

func _process(delta):
	if camino.size() >1:
		var andar = delta*VELOCIDAD
		while andar > 0 and camino.size() >= 2:
			var ptInicio = camino[camino.size()-1]
			var ptFin = camino[camino.size()-2]
			var distancia = ptInicio.distance_to(ptFin)
			if distancia < andar:
				camino.remove(camino.size()-1)
				andar = distancia
			else:
				camino[camino.size()-1] = ptInicio.linear_interpolate(ptFin, andar/distancia)
				andar = 0
	
		set_pos(Vector2(camino[camino.size()-1].x +32, camino[camino.size()-1].y-80))

		if camino.size() < 2:
			camino = []
			set_process(false)
			if global.LISTA_POSICIONES.size()> 0:
				ejecutarBusqueda()
	else:
		camino = []
		set_process(false)
		if global.LISTA_POSICIONES.size()> 0:
			ejecutarBusqueda()



func limpiarCamino():
	
	var i = camino.size()-1
	var cont = 0
	var salida = false

	while not salida and is_processing():
		#izquierda
		if camino[i-1].y != camino[i].y or camino[i-1].x != camino[i].x-1:
			cont += 1
		
		#derecha
		if camino[i-1].y != camino[i].y or camino[i-1].x != camino[i].x+1:
			cont += 1
		
		#arriba
		if camino[i-1].y != camino[i].y-1 or camino[i-1].x != camino[i].x:
			cont += 1
		
		#abajo
		if camino[i-1].y != camino[i].y+1 or camino[i-1].x != camino[i].x:
			cont += 1
		
		if cont == 4:
			camino.remove(i-1)
		else:
			i -= 1
		
		cont = 0
		if i <= 0:
			salida = true
	
	return camino

func transformarCamino():
	var v = []
	for elemento in camino:
		if matrizNivel[elemento.x][elemento.y].x >= 0:
			v.append(matrizNivel[elemento.x][elemento.y])
	
	return v

func ejecutarBusqueda():
	if global.LISTA_POSICIONES.size() > 0 and not is_processing():
		buscando = true
		posInicial = convertirPosicion(global.ACTUAL_ENEMIGO)
		
		var p = global.LISTA_POSICIONES[global.LISTA_POSICIONES.size()-1]
		global.LISTA_POSICIONES.pop_front()
		posFinal = convertirPosicion(p)
		global.ACTUAL_ENEMIGO = p

		camino = generarCamino(posInicial, posFinal)
		print(camino)
		var aux = []
		for elemento in camino:
			aux.append(matrizNivel[elemento.x][elemento.y])
		
		print(aux)

		aux = []
		for elemento in camino:
			if matrizNivel[elemento.x][elemento.y].x >= 0: 
				aux.append(matrizNivel[elemento.x][elemento.y])
		print(aux)

		# camino = limpiarCamino()
		camino = transformarCamino()
		camino.invert()
		set_process(true)
	
func _ready():
	set_z(99)
	crearMatrizNivel1()
	inicializarEscaleras()
	generarMatriz()