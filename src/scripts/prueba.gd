extends Area2D

onready var sprite = get_node("sprite")
onready var animaciones = get_node("animaciones")
onready var rayIzq = get_node("rayIzq")
onready var rayDer = get_node("rayDer")
onready var eje = get_node("eje")

var anima0 = ""
var anima1 = ""
var izquierda = true
var direccion = Vector2()
var posActual= Vector2()
var en_suelo = false
var limites = Vector2()

var diff = 32
var dirMovimiento = [true, true]
var dirMovimientoAux = [false, false]
var centroEjeEscalera = 0
var movHorizontal = true

var movVertical = {"arriba":false, "abajo":false, "abajo2":false}
var vectorEscaleras = []

var sobreEscalera = false
var bajarEscalera = false
var entradaEscalera = false
var boolTeclaAbajo = false

func _ready():
	rayIzq.add_exception(self)
	rayDer.add_exception(self)
	set_fixed_process(true)
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.KEY:
		if event.scancode == KEY_DOWN and event.pressed == false:
			pass

func _fixed_process(delta):
	movimiento(delta)
	animacion()
	colisionesAbajo()
	
func movimiento(delta):
	# print(get_pos().y)
	anima1 = anima0
	posActual = get_pos()

	if movHorizontal and dirMovimiento[0] and Input.is_action_pressed("tecla_izq"):
		anima0 = "caminar"
		izquierda = true
		direccion = Vector2(-1, 0)
		
	elif movHorizontal and dirMovimiento[1] and Input.is_action_pressed("tecla_der"):
		anima0 = "caminar"
		izquierda = false
		direccion = Vector2(1, 0)
	else:
		direccion.x = 0
		anima0 = "idle"
	
	if entradaEscalera and vectorEscaleras.size() > 0 and Input.is_action_pressed("tecla_abajo"):
		rayIzq.add_exception(vectorEscaleras[0])
		rayDer.add_exception(vectorEscaleras[0])
		boolTeclaAbajo = true
		print("tecla abajo!")
	
	elif entradaEscalera and vectorEscaleras.size() > 0 and Input.is_action_pressed("tecla_arriba"):
		vectorEscaleras.clear()
	
	#------------------------------------------
	elif bajarEscalera and limites.y > eje.get_global_pos().y and Input.is_action_pressed("tecla_abajo"):
		direccion = Vector2(0, 1)
		movHorizontal = false
	elif bajarEscalera and limites.y <= eje.get_global_pos().y and Input.is_action_pressed("tecla_abajo"):
		movHorizontal = true
		direccion.y = 0
	
	elif bajarEscalera and limites.x < eje.get_global_pos().y and Input.is_action_pressed("tecla_arriba"):
		direccion = Vector2(0, -1)
		movHorizontal = false
		print("llllllllllllllll")
	elif bajarEscalera and limites.x >= eje.get_global_pos().y and Input.is_action_pressed("tecla_arriba"):
		
		bajarEscalera = false
		movHorizontal = true
		direccion.y = 0
	else:
		direccion.y = 0
	#------------------------------------------
	
	var posFinal = posActual+(direccion*global.VELOCIDAD*delta)
	set_pos(posFinal)
	
func animacion():
	sprite.set_flip_h(izquierda)
	if anima1 != anima0:
		animaciones.play(anima0)

func colisionesAbajo():
	if rayIzq.is_colliding() and rayDer.is_colliding():
		if rayIzq.get_collider().is_in_group("escaleras") and rayDer.get_collider().is_in_group("escaleras"):
			var obj = rayIzq.get_collider()
			if not sobreEscalera:
				entradaEscalera = true
				sobreEscalera = true
				agregarEscalera(obj)
				print("dentro!: "+obj.get_name())
		
			if boolTeclaAbajo and sobreEscalera and vectorEscaleras.size() >= 0:
				boolTeclaAbajo = false
				print("bb: "+obj.get_name())
				entradaEscalera = false
				bajarEscalera = true
				limites.x = rayIzq.get_collider().limiteSuperior
				limites.y = rayIzq.get_collider().limiteInferior 
				centroEjeEscalera = rayDer.get_collider().centro
				# entra arriba
				if centroEjeEscalera.y-diff > eje.get_global_pos().y:
					dirMovimiento = [rayIzq.get_collider().arribaIzq, rayIzq.get_collider().arribaDer]
					dirMovimientoAux= [rayIzq.get_collider().abajoIzq, rayIzq.get_collider().abajoDer]
				# entra abajo
				elif centroEjeEscalera.y-diff <= eje.get_global_pos().y:
					dirMovimiento = [rayIzq.get_collider().abajoIzq, rayIzq.get_collider().abajoDer]
					dirMovimientoAux= [rayIzq.get_collider().arribaIzq, rayIzq.get_collider().arribaDer]
	
	else:
		if sobreEscalera and not entradaEscalera:
			boolTeclaAbajo = false
			bajarEscalera = false
			sobreEscalera = false
			entradaEscalera = false
			dirMovimiento = [true, true]
			dirMovimientoAux = [true, true]
			if vectorEscaleras.size() > 0:
				rayIzq.remove_exception(vectorEscaleras[0])
				rayDer.remove_exception(vectorEscaleras[0])
			vectorEscaleras.clear()
			print("fuera!")
		
		elif boolTeclaAbajo and entradaEscalera and vectorEscaleras.size() > 0:
			print("aqi!")
			rayIzq.remove_exception(vectorEscaleras[0])
			rayDer.remove_exception(vectorEscaleras[0])
			vectorEscaleras.clear()
			
func agregarEscalera(obj):
	var resultado = false
	if not existeObjeto(obj):
		vectorEscaleras.append(obj)
		resultado = true
	return resultado

func existeObjeto(obj):
	var resultado = false
	for elemento in vectorEscaleras:
		if elemento == obj:
			resultado = true
			break	
	return resultado