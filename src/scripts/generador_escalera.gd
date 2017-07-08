extends Node2D

export var filas = 1
export var columnas = 1 
export var azul = true
export var largo = 32
export var ancho = 32
export var arribaIzq= false
export var arribaDer = false
export var abajoIzq = false
export var abajoDer = false
export var ocultarShape = false
export var pisoArriba = -1
export var pisoAbajo = -1

onready var posicion = get_node("posicion")
onready var shape = get_node("shape")

var pos = Vector2()
var limiteSuperior = 0
var limiteInferior = 0
var centro = Vector2()

var rectShape = RectangleShape2D.new()

func _ready():
	add_to_group("escaleras")
	centro = posicion.get_global_pos()
	crearShape()
	pos = posicion.get_pos()
	construirEscalera()
	set_process(true)

func _process(delta):
	generarShape()

func generarShape():
	if ocultarShape and shape.get_shape() != null:
		shape.set_shape(null)
		print("ocultar!")
		
	elif not ocultarShape and shape.get_shape() == null:
		print("mostrar!")

func crearShape():
	if shape.get_shape() == null and not ocultarShape:
		shape.set_shape(rectShape)
		shape.get_shape().set_extents(Vector2(16*columnas, 16*filas))
		shape.set_pos(Vector2((ancho*columnas)/2, -(largo*filas)/2))
		if not is_a_parent_of(shape):
			add_child(shape)
		
func construirEscalera():
	var posX = pos.x + 16
	var posY = pos.y - 16
	
	var obj = null
	
	limiteInferior = posicion.get_global_pos().y - 2
	for fila in range(0, filas):
		for columna in  range(0, columnas):
			obj = preload("res://src/escenas/escalera.tscn").instance()
			obj.set_pos(Vector2(posX, posY))
			obj.azul = azul
			posX += ancho
			add_child(obj)
		posX = pos.x + 16
		posY -= ancho

	limiteSuperior = posicion.get_global_pos().y-(largo*filas)

func _on_generador_escaleras_area_enter( area ):
	if(area.get_name() == "chef"):
		global.EN_ESCALERA = true

func _on_generador_escaleras_area_exit( area ):
	if(area.get_name() == "chef"):
		global.EN_ESCALERA = false


