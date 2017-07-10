extends Area2D

onready var sprite = get_node("sprite")
onready var eje = get_node("eje")
onready var rayIzq = get_node("rayIzq")
onready var rayDer = get_node("rayIzq")
onready var animacion = get_node("animacion")

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

# 0: derecha, 1: izquierda, 2: arriba, 3:abajo
var direcionAnima = 0
var anima0 = ""
var anima1 = anima0


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
				v = [Vector2(p0, p1), Vector2(fila, columna)]
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


func existeAbierto(elemento, arreglo):
	for i in range(arreglo.size()):
		if arreglo[i][0].x == elemento.x and arreglo[i][0].y == elemento.y:
			return true
	return false
	
func existeCerrado(elemento, arreglo):
	for token in arreglo:
		if token.x == elemento.x and token.y == elemento.y:
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
	var auxCamino = []

	while pActual.x != pFinal.x or pActual.y != pFinal.y:
		vCerrado.append(Vector2(pActual.x, pActual.y))
		#izquierda
		if pActual.y > 0 and matrizNivel[pActual.x][pActual.y-1].x != -2 and not existeCerrado(Vector2(pActual.x, pActual.y-1), vCerrado) and not existeAbierto(Vector2(pActual.x, pActual.y-1), vAbierto):
			h = abs(pActual.x-pFinal.x)+abs((pActual.y-1)-pFinal.y) 
			f = h + 10 
			auxCamino.append([Vector2(pActual.x, pActual.y-1), f])
		#derecha
		if pActual.y < (COLUMNAS-1) and matrizNivel[pActual.x][pActual.y+1].x != -2 and not existeCerrado(Vector2(pActual.x, pActual.y+1), vCerrado) and not existeAbierto(Vector2(pActual.x, pActual.y+1), vAbierto):
			h = abs(pActual.x-pFinal.x)+abs((pActual.y+1)-pFinal.y) 
			f = h + 10
			auxCamino.append([Vector2(pActual.x, pActual.y+1), f])
		#arriba OJO
		if pActual.x > 0 and matrizNivel[pActual.x][pActual.y].x != -1 and matrizNivel[pActual.x-1][pActual.y].y != -2 and matrizNivel[pActual.x-1][pActual.y].y != -1 and not existeCerrado(Vector2(pActual.x-1, pActual.y), vCerrado) and not existeAbierto(Vector2(pActual.x-1, pActual.y), vAbierto):
			h = abs((pActual.x-1)-pFinal.x)+abs(pActual.y-pFinal.y) 
			f = h + 10
			auxCamino.append([Vector2(pActual.x-1, pActual.y), f])
		#abajo OJO
		if pActual.x < (FILAS-1) and matrizNivel[pActual.x][pActual.y].x != -1 and matrizNivel[pActual.x+1][pActual.y].y != -2 and matrizNivel[pActual.x+1][pActual.y].y != -1 and not existeCerrado(Vector2(pActual.x+1, pActual.y), vCerrado) and not existeAbierto(Vector2(pActual.x+1, pActual.y), vAbierto):
			h = abs((pActual.x+1)-pFinal.x)+abs(pActual.y-pFinal.y) 
			f = h + 10
			auxCamino.append([Vector2(pActual.x+1, pActual.y), f])
		
		var c = 1000
		var posEleminar = 0
		var actualizar = false
		
		for i in range(auxCamino.size()):
			if c > auxCamino[i][1]:
				c = auxCamino[i][1]
				posEleminar = i
		
		for i in range(vAbierto.size()):
			if c > vAbierto[i][1]:
				c = vAbierto[i][1]
				posEleminar = i
				actualizar = true

		vCamino.append(pActual)
		
		if not actualizar:
			pActual = auxCamino[posEleminar][0]
			auxCamino.remove(posEleminar)
		else:
			pActual = vAbierto[posEleminar][0]
			vAbierto.remove(posEleminar)
			# examinar elemento continuos
			var lista = []
			var bandera = false
			var i = vCamino.size()-1
			
			while not bandera:
				#izquierda
				if vCamino[i].y == pActual.y-1 and vCamino[i].x == pActual.x:
					bandera = true
				# derecha
				elif vCamino[i].y == pActual.y+1 and vCamino[i].x == pActual.x:
					bandera = true
				# arriba
				elif vCamino[i].x == pActual.x-1 and vCamino[i].y == pActual.y:
					bandera = true
				# abajo
				elif vCamino[i].x == pActual.x+1 and vCamino[i].y == pActual.y:
					bandera = true
				
				if not bandera:
					lista.append(i)
					if (i-1) > 0:
						i -= 1
					else:
						bandera = true
			
			for pos in lista:
				vCamino.remove(pos)
		
		for elemento in auxCamino:
			vAbierto.append(elemento)

		auxCamino = []

	vCamino.append(pActual)

	return vCamino

func convertirPosicion(posicion):
	for i in range(matrizNivel.size()):
		for j in range(matrizNivel[i].size()):
			if posicion.x == matrizNivel[i][j].x and posicion.y == matrizNivel[i][j].y:
				return [i, j]
	return [-1, -1]

func animacion():
	anima1 = anima0
	#derecha
	if direcionAnima == 0:
		sprite.set_flip_h(false)
		anima0 = "caminar"
	#izquierda
	elif direcionAnima == 1:
		sprite.set_flip_h(true)
		anima0 = "caminar"
	#arriba
	elif direcionAnima == 2:
		anima0 = "escaleras"
	#abajo
	elif direcionAnima == 3:
		anima0 = "escaleras"
		
	if anima0 != anima1:
		animacion.play(anima0)

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
		#izquierda
		if get_pos().x > (camino[camino.size()-1].x +32):
			direcionAnima = 1
		
		#derecha
		elif get_pos().x < (camino[camino.size()-1].x +32):
			direcionAnima = 0
		
		#arriba
		elif get_pos().y > (camino[camino.size()-1].y-80):
			direcionAnima = 2
		
		#abajo
		elif get_pos().y < (camino[camino.size()-1].y-80):
			direcionAnima = 3

		animacion()
		set_pos(Vector2(camino[camino.size()-1].x +32, camino[camino.size()-1].y-80))

		if camino.size() < 2:
			camino = []
			set_process(false)
			if global.LISTA_POSICIONES.size()> 0:
				ejecutarBusqueda()
			else:
				movimientoFinal()
	else:
		camino = []
		set_process(false)
		if global.LISTA_POSICIONES.size()> 0:
			ejecutarBusqueda()
		else:
			movimientoFinal()

func movimientoFinal():
	var diff = 5
	#arriba
	if global.ACTUAL_VERONICA.y > chef.eje.get_global_pos().y+diff:
		hallarPunto(0)
	
	#abajo
	elif global.ACTUAL_VERONICA.y < chef.eje.get_global_pos().y-diff:
		hallarPunto(1)
	#izquierda
	elif global.ACTUAL_VERONICA.x > chef.eje.get_global_pos().x:
		hallarPunto(2)
	#derecha
	elif global.ACTUAL_VERONICA.x < chef.eje.get_global_pos().x:
		hallarPunto(3)

func hallarPunto(tipo):
	var p = convertirPosicion(global.ACTUAL_VERONICA)
	var p1 = null
	# busqueda por la arriba
	if tipo == 0:
		for i in range(1, FILAS):
			if (p[0]-i) >= 0 and matrizNivel[p[0]-i][p[1]].x >= 0:
				print("entra izq: "+str(matrizNivel[p[0]-i][p[1]].x))
				p1 = Vector2(p[0]-i, p[1])
				break
	# busqueda por la abajo
	elif tipo == 1:
		for i in range(1, FILAS):
			if (p[0]+i) < FILAS and matrizNivel[p[0]+i][p[1]].x >= 0:
				print("entra izq: "+str(matrizNivel[p[0]+i][p[1]].x))
				p1 = Vector2(p[0]+i, p[1])
				break
	elif tipo == 2:
		for i in range(1, COLUMNAS):
			if (p[1]-i) >= 0 and matrizNivel[p[0]][p[1]-i].x >= 0:
				print("entra izq: "+str(matrizNivel[p[0]][p[1]-i].x))
				p1 = Vector2(p[0], p[1]-i)
				break

	# busqueda por la derecha
	elif tipo == 3:
		for i in range(1, COLUMNAS):
			if (p[1]+i < COLUMNAS) and matrizNivel[p[0]][p[1]+i].x >= 0:
				print("entra der: "+str(matrizNivel[p[0]][p[1]+i].x))				
				p1 = Vector2(p[0], p[1]+i)
				break
	if p1 != null:
		global.LISTA_POSICIONES.append(Vector2(matrizNivel[p1.x][p1.y].x, matrizNivel[p1.x][p1.y].y))
		ejecutarBusqueda()

func transformarCamino():
	var v = []
	for elemento in camino:
		if matrizNivel[elemento.x][elemento.y].x >= 0:
			v.append(matrizNivel[elemento.x][elemento.y])
	
	return v

func ejecutarBusqueda():
	if global.LISTA_POSICIONES.size() > 0 and not is_processing():
		buscando = true
		posInicial = convertirPosicion(global.ACTUAL_VERONICA)
		
		var p = global.LISTA_POSICIONES[global.LISTA_POSICIONES.size()-1]
		global.LISTA_POSICIONES.pop_front()
		posFinal = convertirPosicion(p)
		global.ACTUAL_VERONICA = p
		
		camino = generarCamino(posInicial, posFinal)
		
		var aux = []
		for elemento in camino:
			aux.append(matrizNivel[elemento.x][elemento.y])
		
		camino = transformarCamino()
		camino.invert()
		set_process(true)
	
func _ready():
	set_z(99)
	crearMatrizNivel1()
	inicializarEscaleras()
	generarMatriz()
	var pos = localizarPosicion(chef)
	global.LISTA_POSICIONES.append(Vector2(matrizNivel[pos.x][pos.y].x, matrizNivel[pos.x][pos.y].y))
	ejecutarBusqueda()