extends Node2D

var FILAS = 6
var COLUMNAS = 6

var matriz = []
var vInicio = Vector2(5, 0)
var vFin = Vector2(0, 5)
var vActual = vInicio

var vCerrado = []
var vAbierto = []

func crearMatriz():
	var vector = []
	
	for i in range(FILAS):
		for j in range(COLUMNAS):
			vector.append(" ")
		matriz.append(vector)
		vector = []
		
	
	matriz[4][0] = "#"
	matriz[5][2] = "#"
	matriz[1][3] = "#"
	matriz[2][3] = "#"
	matriz[3][3] = "#"
	# matriz[3][4] = "#"
	matriz[3][5] = "#"
	
	matriz[vFin.x][vFin.y] = "F"
	matriz[vInicio.x][vInicio.y] = "I"

func imprimirMatriz():
	for vector in matriz:
		print(vector)

func existeCerrado(posicion):
	for elemento in vCerrado:
		if elemento.x == posicion.x and elemento.y == posicion.y:
			return true
	return false

func generarRuta():
	var h = 0
	var f = 0
	var vAux = []
	var ruta = []
	while vActual.x != vFin.x or vActual.y != vFin.y:
		vCerrado.append(vActual)
		vAux = []	
		print(vActual)
		#izquierda
		if vActual.x > 0 and matriz[vActual.x-1][vActual.y] != "#" and not existeCerrado(Vector2(vActual.x-1, vActual.y)):
			h = abs((vActual.x-1)-vFin.x)+abs(vActual.y-vFin.y)	
			f = h + 10
			vAbierto.append([[vActual.x-1, vActual.y], f]) 
		#derecha
		if vActual.x < (COLUMNAS-1) and matriz[vActual.x+1][vActual.y] != "#" and not existeCerrado(Vector2(vActual.x+1, vActual.y)):
			h = abs((vActual.x+1)-vFin.x)+abs(vActual.y-vFin.y)	
			f = h + 10
			vAbierto.append([[vActual.x+1, vActual.y], f]) 
						
		#arriba
		if vActual.y > 0 and matriz[vActual.x][vActual.y-1] != "#" and not existeCerrado(Vector2(vActual.x, vActual.y-1)):
			h = abs((vActual.x)-vFin.x)+abs((vActual.y-1)-vFin.y)	
			f = h + 10
			vAbierto.append([[vActual.x, vActual.y-1], f]) 
			
		#abajo
		if vActual.y < (FILAS-1) and matriz[vActual.x][vActual.y+1] != "#" and not existeCerrado(Vector2(vActual.x, vActual.y+1)):
			h = abs((vActual.x)-vFin.x)+abs((vActual.y+1)-vFin.y)	
			f = h + 10
			vAbierto.append([[vActual.x, vActual.y+1], f]) 
		
		var c= 0
		var posEliminar = -1
		for i in range(vAbierto.size()):
			if i == 0:
				c = vAbierto[i][1]
				posEliminar = i
			else:
				if c > vAbierto[i][1]:
					c = vAbierto[i][1]
					posEliminar = i
		
		ruta.append(vActual)
		vActual = Vector2(vAbierto[posEliminar][0][0], vAbierto[posEliminar][0][1])
		vAbierto.remove(posEliminar)
	
	return limpiarRuta(ruta)

func limpiarRuta(ruta):
	print("antes: ")
	print(ruta)
	print()
	var cont = 0
	var i = ruta.size()-1
	var salida = false

	while not salida:
		cont = 0
		#izquierda
		if (ruta[i-1].x != ruta[i].x) or (ruta[i-1].y != ruta[i].y-1):
			cont += 1
		
		#derecha
		if (ruta[i-1].x != ruta[i].x) or (ruta[i-1].y != ruta[i].y+1):
			cont += 1
		
		#arriba
		if (ruta[i-1].x != ruta[i].x-1) or (ruta[i-1].y != ruta[i].y):
			cont += 1
		
		#abajo
		if (ruta[i-1].x != ruta[i].x+1) or (ruta[i-1].y != ruta[i].y):
			cont += 1
		
		if cont == 4:
			ruta.remove(i-1)
		else:
			i -= 1
		
		if i <= 1:
			salida = true		
	return ruta

func dibujarRuta(ruta):
	for elemento in ruta:
		matriz[elemento.x][elemento.y] = "+"

func _ready():
	crearMatriz()
	imprimirMatriz()
	var ruta = generarRuta()
	dibujarRuta(ruta)
	imprimirMatriz()
	# print(ruta)
