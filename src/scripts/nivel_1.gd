extends Node2D

export var FILAS = 8
export var COLUMNAS = 17

var escaleras = {}
var matrizNivel = []
var enEscena = false


func _ready():
	global.ESCENA_ACTUAL = "nivel_1.tscn"
	crearMatrizNivel()
	inicializarEscaleras()
	generarMatriz()
	print("Escena actual: "+global.ESCENA_ACTUAL)

func inicializarEscaleras():
	enEscena = true
	var nodoEscaleras = get_node("escaleras")
	for nodo in nodoEscaleras.get_children():
		var clave = int(nodo.get_name())
		escaleras[clave] = []
		for escalera in nodo.get_children():
			escaleras[clave].append(escalera)

func crearMatrizNivel():
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