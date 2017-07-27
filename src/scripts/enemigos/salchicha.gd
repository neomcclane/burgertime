extends Area2D

export var vecInicial = Vector2()
export var vecReinicio = Vector2(-1, -1)
export var diffAlimentoCaida = 40

onready var sprite = get_node("sprite")
onready var eje = get_node("eje")
onready var animacion = get_node("animacion")
onready var ray = get_node("ray")
onready var raiz = get_owner()

var auxVecInicial = null
var VELOCIDAD = 140

var chef = null
var pisoActual = 0
var posX = 0
var posY = 0
var posInicial = []
var posFinal = []
var camino = []

var buscando = false

# 0: derecha, 1: izquierda, 2: arriba, 3:abajo
var direcionAnima = 0
var anima0 = ""
var anima1 = anima0

var avanzar = true
var detenido = false
var tiempoDetenido = 0
var tiempoDetenidoMax = 5.0

var eliminado = false
var tiempoEliminado = 0
var tiempoEliminadoMax = 2

var dentroAlimento = null
var caer = false

func _ready():
	add_to_group("enemigos")
	set_z(100)
	if vecReinicio.x != -1 and vecReinicio.y != -1:
		auxVecInicial = vecReinicio
	else:
		auxVecInicial = vecInicial

	ray.add_exception(self)
	chef = raiz.get_node("chef")
	
	set_fixed_process(true)


func localizarPosicion(player):
	var posChef = player.eje.get_global_pos()
	var diff = 5
	var posAux = null
	var salida = false
	var v = []
	
	var p0 = null
	var p1 = null

	for fila in range(raiz.FILAS):
		for columna in range(raiz.COLUMNAS):
			if posAux != null and posAux.y == raiz.matrizNivel[fila][columna].y and raiz.matrizNivel[fila][columna].y+diff >= posChef.y and raiz.matrizNivel[fila][columna].x+32 >= posChef.x:
				v = [Vector2(p0, p1), Vector2(fila, columna)]
				salida = true	
				break
			elif raiz.matrizNivel[fila][columna].x != -1 and raiz.matrizNivel[fila][columna].x != -2:
				p0 = fila
				p1 = columna
				posAux = raiz.matrizNivel[fila][columna]

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
		if pActual.y > 0 and raiz.matrizNivel[pActual.x][pActual.y-1].x != -2 and not existeCerrado(Vector2(pActual.x, pActual.y-1), vCerrado) and not existeAbierto(Vector2(pActual.x, pActual.y-1), vAbierto):
			h = abs(pActual.x-pFinal.x)+abs((pActual.y-1)-pFinal.y) 
			f = h + 10 
			auxCamino.append([Vector2(pActual.x, pActual.y-1), f])
		#derecha
		if pActual.y < (raiz.COLUMNAS-1) and raiz.matrizNivel[pActual.x][pActual.y+1].x != -2 and not existeCerrado(Vector2(pActual.x, pActual.y+1), vCerrado) and not existeAbierto(Vector2(pActual.x, pActual.y+1), vAbierto):
			h = abs(pActual.x-pFinal.x)+abs((pActual.y+1)-pFinal.y) 
			f = h + 10
			auxCamino.append([Vector2(pActual.x, pActual.y+1), f])
		#arriba OJO
		if pActual.x > 0 and raiz.matrizNivel[pActual.x][pActual.y].x != -1 and raiz.matrizNivel[pActual.x-1][pActual.y].y != -2 and raiz.matrizNivel[pActual.x-1][pActual.y].y != -1 and not existeCerrado(Vector2(pActual.x-1, pActual.y), vCerrado) and not existeAbierto(Vector2(pActual.x-1, pActual.y), vAbierto):
			h = abs((pActual.x-1)-pFinal.x)+abs(pActual.y-pFinal.y) 
			f = h + 10
			auxCamino.append([Vector2(pActual.x-1, pActual.y), f])
		#abajo OJO
		if pActual.x < (raiz.FILAS-1) and raiz.matrizNivel[pActual.x][pActual.y].x != -1 and raiz.matrizNivel[pActual.x+1][pActual.y].y != -2 and raiz.matrizNivel[pActual.x+1][pActual.y].y != -1 and not existeCerrado(Vector2(pActual.x+1, pActual.y), vCerrado) and not existeAbierto(Vector2(pActual.x+1, pActual.y), vAbierto):
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
	for i in range(raiz.matrizNivel.size()):
		for j in range(raiz.matrizNivel[i].size()):
			if posicion.x == raiz.matrizNivel[i][j].x and posicion.y == raiz.matrizNivel[i][j].y:
				return [i, j]
	return [-1, -1]

func animacion():
	anima1 = anima0
	if not eliminado and avanzar:
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
	
	elif not eliminado and direcionAnima > 1:
		anima0 = "idleEscalera"
	
	elif detenido:
		anima0 = "detenido"
	elif not avanzar:
		anima0 = "idle"

	if anima0 != anima1:
		animacion.play(anima0)

func _process(delta):
	if avanzar and camino.size() >1:
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
		elif get_pos().y > (camino[camino.size()-1].y-90):
			direcionAnima = 2
		
		#abajo
		elif get_pos().y < (camino[camino.size()-1].y-90):
			direcionAnima = 3

		animacion()
		set_pos(Vector2(camino[camino.size()-1].x +32, camino[camino.size()-1].y-45))
		
		if camino.size() < 2:
			camino = []
			set_process(false)
			if global.LISTA_POSICIONES.size()> 0:
				ejecutarBusqueda()
			else:
				movimientoFinal()
	elif avanzar:
		camino = []
		set_process(false)
		if global.LISTA_POSICIONES.size()> 0:
			ejecutarBusqueda()
		else:
			movimientoFinal()

func movimientoFinal():
	var diff = 10
	#arriba
	if vecInicial.y > chef.eje.get_global_pos().y+diff:
		hallarPunto(0)
	#abajo
	elif vecInicial.y < chef.eje.get_global_pos().y-diff:
		hallarPunto(1)
	#izquierda
	elif vecInicial.x > chef.eje.get_global_pos().x:
		hallarPunto(2)
	#derecha
	elif vecInicial.x < chef.eje.get_global_pos().x:
		hallarPunto(3)

func hallarPunto(tipo):
	var p = convertirPosicion(vecInicial)
	var p1 = null
	# busqueda por la arriba
	if tipo == 0:
		for i in range(1, raiz.FILAS):
			if (p[0]-i) >= 0 and raiz.matrizNivel[p[0]-i][p[1]].x >= 0:
				p1 = Vector2(p[0]-i, p[1])
				break

	# busqueda por la abajo
	elif tipo == 1:
		for i in range(1, raiz.FILAS):
			if (p[0]+i) < raiz.FILAS and raiz.matrizNivel[p[0]+i][p[1]].x >= 0:
				p1 = Vector2(p[0]+i, p[1])
				break

	elif tipo == 2:
		for i in range(1, raiz.COLUMNAS):
			if (p[1]-i) >= 0 and raiz.matrizNivel[p[0]][p[1]-i].x >= 0:
				p1 = Vector2(p[0], p[1]-i)
				break

	# busqueda por la derecha
	elif tipo == 3:
		for i in range(1, raiz.COLUMNAS):
			if (p[1]+i < raiz.COLUMNAS) and raiz.matrizNivel[p[0]][p[1]+i].x >= 0:
				p1 = Vector2(p[0], p[1]+i)
				break
	if p1 != null:
		global.LISTA_POSICIONES.append(Vector2(raiz.matrizNivel[p1.x][p1.y].x, raiz.matrizNivel[p1.x][p1.y].y))
		ejecutarBusqueda()

func transformarCamino():
	var v = []
	for elemento in camino:
		if raiz.matrizNivel[elemento.x][elemento.y].x >= 0:
			v.append(raiz.matrizNivel[elemento.x][elemento.y])
	
	return v

func ejecutarBusqueda():
	if global.LISTA_POSICIONES.size() > 0 and not is_processing():
		buscando = true
		posInicial = convertirPosicion(vecInicial)
		
		var p = global.LISTA_POSICIONES[global.LISTA_POSICIONES.size()-1]
		global.LISTA_POSICIONES.pop_front()
		posFinal = convertirPosicion(p)
		vecInicial = p
		
		camino = generarCamino(posInicial, posFinal)
		
		var aux = []
		for elemento in camino:
			aux.append(raiz.matrizNivel[elemento.x][elemento.y])
		
		camino = transformarCamino()
		camino.invert()
		set_process(true)


	
func _fixed_process(delta):
	colisionCabeza()
	analisisMovimiento(delta)
	analisisCaida()
	
func analisisCaida():
	if dentroAlimento != null and not caer:
		if dentroAlimento.bajar and dentroAlimento.eje.get_global_pos().y >= self.eje.get_global_pos().y +10:
			detenido = true
			avanzar = false
			caer = true
			dentroAlimento.contadorCaida = 1
			animacion()
	
	#Caer con el alimento
	if dentroAlimento != null and dentroAlimento.banderaCaidaContinua and caer:
		self.set_z(199)
		set_global_pos(Vector2(self.get_global_pos().x, dentroAlimento.get_global_pos().y-diffAlimentoCaida))

	elif dentroAlimento != null and not dentroAlimento.banderaCaidaContinua and caer:
		reiniciarEnemigo()

func analisisMovimiento(delta):
	if not caer and not eliminado and detenido and tiempoDetenido > tiempoDetenidoMax:
		tiempoDetenido = 0
		detenido = false
		avanzar = true
		if global.LISTA_POSICIONES.size()> 0:
			ejecutarBusqueda()
		else:
			movimientoFinal()

	elif not caer and not eliminado and detenido and tiempoDetenido <= tiempoDetenidoMax:
		tiempoDetenido += 1*delta
	
	elif not caer and eliminado and not detenido and tiempoEliminado <= tiempoEliminadoMax:
		tiempoEliminado += 1 *delta
	
	elif not caer and eliminado and not detenido and tiempoEliminado > tiempoEliminadoMax:
		#global.LISTA_POSICIONES = []
		tiempoEliminado = 0
		avanzar = true
		eliminado = false
		vecInicial = auxVecInicial
		camino = []
		movimientoFinal()
		self.show()

func colisionCabeza():
	if ray.is_colliding():
		if ray.get_collider().is_in_group("alimento") and ray.get_collider().bajar:
			reiniciarEnemigo()

func reiniciarEnemigo():
	self.hide()
	set_z(100)
	avanzar = false
	detenido = false
	eliminado = true
	caer = false
	dentroAlimento = null
	self.set_pos(Vector2(auxVecInicial.x, auxVecInicial.y-45))
	animacion()

func _on_salchiha_area_enter( area ):
	if area.get_name() == "chef" and not global.EMITIENDO_PIMIENTA:
		avanzar = false
		animacion()
		
	elif (area.is_in_group("pimienta") or area.get_name() == "chef") and global.EMITIENDO_PIMIENTA:
		detenido = true
		avanzar = false
		animacion()

	elif area.is_in_group("alimento"):
		dentroAlimento = area

func _on_salchiha_area_exit( area ):
	if area.is_in_group("alimento"):
		dentroAlimento = null
