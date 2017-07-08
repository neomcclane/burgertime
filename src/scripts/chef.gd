extends Area2D

onready var sprite = get_node("sprite")
onready var animaciones = get_node("animaciones")
onready var rayIzq = get_node("rayIzq")
onready var rayDer = get_node("rayDer")
onready var eje = get_node("eje")
onready var marina = get_parent().get_node("enemigo")

var anima0 = ""
var anima1 = ""
var izquierda = true
var direccion = Vector2()
var posActual= Vector2()
var en_suelo = false
var limites = Vector2()

var diff = 16
var dirMovimiento = [true, true]
var dirMovimientoAux = [false, false]
var centroEjeEscalera = 0
var movHorizontal = true

var movVertical = {"arriba":false, "abajo":false, "abajo2":false}
var vectorEscaleraExcepcion = []
var vectorEscaleraColision = []
var sobreEscalera = false
var arribaEscalera = false
var abajoEscalera = false
var evaluarEscaleraAbajo = false
var bajarEscaleraDoble = false

var bajarEscaleraNormal = false
var teclaAbajoEscaleraNormal = false

var subirEscaleraNormal = false

var llegoArribaEscalera = false
var llegoAbajoEscalera = false

var limiteInferiorEscalera = false
var limiteSuperiorEscalera = false

var animaQuieto = ["animaEscaleraQuietoIzq", "animaEscaleraQuietoDer"]
var animaQuietoAux = ""

func _ready():
	print("enemigo--> "+marina.get_name())
	set_z(100)
	rayIzq.add_exception(self)
	rayDer.add_exception(self)
	set_fixed_process(true)
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.KEY:
		if limiteInferiorEscalera and event.scancode == KEY_UP and event.pressed:
			resetearVariablesActualizarSuelo()
		elif limiteInferiorEscalera and event.scancode == KEY_DOWN and not event.pressed: # == false
			resetearVariablesActualizarSuelo()
		elif limiteSuperiorEscalera and event.scancode == KEY_DOWN and event.pressed:
			resetearVariablesActualizarSuelo()
		elif limiteSuperiorEscalera and event.scancode == KEY_UP and not event.pressed: # == false
			resetearVariablesActualizarSuelo()
			
func _fixed_process(delta):
	movimiento(delta)
	animacion()
	colisionesAbajo()
	
func movimiento(delta):
	# print(eje.get_global_pos().y)
	anima1 = anima0
	posActual = get_pos()

	if movHorizontal and dirMovimiento[0] and Input.is_action_pressed("tecla_izq"):
		izquierda = true
		direccion = Vector2(-1, 0)
		
	elif movHorizontal and dirMovimiento[1] and Input.is_action_pressed("tecla_der"):
		izquierda = false
		direccion = Vector2(1, 0)
	else:
		direccion.x = 0

	#------------------------------------------
	#****************************************************
	#****************************************************
	if abajoEscalera and vectorEscaleraColision.size() > 0 and Input.is_action_pressed("tecla_abajo"):
		for elemento in vectorEscaleraColision:
			vectorEscaleraExcepcion.append(elemento)
		vectorEscaleraColision.clear()
		
		rayIzq.add_exception(vectorEscaleraExcepcion[0])
		rayDer.add_exception(vectorEscaleraExcepcion[0])
		evaluarEscaleraAbajo = true
	#****************************************************
	#****************************************************
	
	elif abajoEscalera and  vectorEscaleraColision.size() > 0 and Input.is_action_pressed("tecla_arriba"):
		subirEscaleraNormal = true
	
	elif arribaEscalera and not bajarEscaleraNormal and not teclaAbajoEscaleraNormal and vectorEscaleraColision.size() > 0 and Input.is_action_pressed("tecla_abajo"):
		bajarEscaleraNormal = true
	
	elif bajarEscaleraNormal and Input.is_action_pressed("tecla_arriba"):
		bajarEscaleraNormal = false
		subirEscaleraNormal = true
	
	elif subirEscaleraNormal and Input.is_action_pressed("tecla_abajo"):
		bajarEscaleraNormal = true
		subirEscaleraNormal = false
	
	elif bajarEscaleraDoble and Input.is_action_pressed("tecla_arriba"):
		bajarEscaleraDoble = false
		subirEscaleraNormal = true

	
	if limites.y > eje.get_global_pos().y and (bajarEscaleraDoble or bajarEscaleraNormal) and Input.is_action_pressed("tecla_abajo"):
		direccion = Vector2(0, 1)
		movHorizontal = false
		arribaEscalera = false
		limiteInferiorEscalera = false
		limiteSuperiorEscalera = false
		
	#limite inferior
	elif limites.y <= eje.get_global_pos().y and (bajarEscaleraDoble or bajarEscaleraNormal) and Input.is_action_pressed("tecla_abajo"):
		direccion.y = 0
		movHorizontal = true
		bajarEscaleraNormal = false
		dirMovimiento = dirMovimientoAux
		limiteInferiorEscalera = true
#		print("limite abajo!")
		
	elif limites.x < eje.get_global_pos().y and subirEscaleraNormal and Input.is_action_pressed("tecla_arriba"):
		direccion = Vector2(0, -1)
		movHorizontal = false
		limiteInferiorEscalera = false
		limiteSuperiorEscalera = false
		
	#limite superior
	elif limites.x >= eje.get_global_pos().y and subirEscaleraNormal and Input.is_action_pressed("tecla_arriba"):
#		print("limite arriba!")
		movHorizontal = true
		direccion.y = 0
		dirMovimiento = dirMovimientoAux
		limiteSuperiorEscalera = true
		
	elif not limiteSuperiorEscalera and limites.x+diff >= eje.get_global_pos().y and sobreEscalera:
#		print("limite arriba estatic!")
		limiteSuperiorEscalera = true
		
	elif not  limiteInferiorEscalera and limites.y-diff <= eje.get_global_pos().y and sobreEscalera:
#		print("limite abajo estatic!")
		limiteInferiorEscalera = true
		

	else:
		direccion.y = 0
	#------------------------------------------
	
	if (limiteInferiorEscalera or limiteSuperiorEscalera) and direccion.x == 0:
		anima0 = "animaEscaleraIdle"
		
	elif movHorizontal and direccion.x != 0:
		anima0 = "caminar"
		
	elif (bajarEscaleraDoble or bajarEscaleraNormal or subirEscaleraNormal) and direccion.y != 0:
		anima0 = "animaEscalera"
		
	elif (bajarEscaleraDoble or bajarEscaleraNormal or subirEscaleraNormal) and direccion.y == 0:
		if animaQuietoAux != anima0:
			randomize()
			anima0 = animaQuieto[randi()%2+0]
			animaQuietoAux = anima0
	else:
		anima0 = "idle"
		
	
	var posFinal = posActual+(direccion*global.VELOCIDAD*delta)
	set_pos(posFinal)
	
func animacion():
	sprite.set_flip_h(izquierda)
	if anima1 != anima0:
		animaciones.play(anima0)

func colisionesAbajo():
	if rayIzq.is_colliding() and rayDer.is_colliding():
		if rayIzq.get_collider().is_in_group("escaleras") and rayDer.get_collider().is_in_group("escaleras"):
			if not sobreEscalera and not existeEscaleraExcepcion(rayIzq.get_collider()) and not existeEscaleraColision(rayIzq.get_collider()):
				sobreEscalera = true
				limites.x = rayIzq.get_collider().limiteSuperior
				limites.y = rayIzq.get_collider().limiteInferior 
				centroEjeEscalera = rayDer.get_collider().centro
				
				# estoy arriba
				if centroEjeEscalera.y-diff > eje.get_global_pos().y:
					global.LISTA_POSICIONES.append(Vector2(rayIzq.get_collider().posicion.get_global_pos().x, rayIzq.get_collider().posicion.get_global_pos().y - (rayIzq.get_collider().filas*rayIzq.get_collider().ancho)))
					print(global.LISTA_POSICIONES)
					marina.ejecutarBusqueda()

					arribaEscalera = true
					dirMovimiento = [rayIzq.get_collider().arribaIzq, rayIzq.get_collider().arribaDer]
					dirMovimientoAux= [rayIzq.get_collider().abajoIzq, rayIzq.get_collider().abajoDer]
				# estoy abajo
				elif centroEjeEscalera.y-diff <= eje.get_global_pos().y:
					global.LISTA_POSICIONES.append(rayIzq.get_collider().posicion.get_global_pos())
					print(global.LISTA_POSICIONES)
					marina.ejecutarBusqueda()
					
					abajoEscalera = true
					dirMovimiento = [rayIzq.get_collider().abajoIzq, rayIzq.get_collider().abajoDer]
					dirMovimientoAux= [rayIzq.get_collider().arribaIzq, rayIzq.get_collider().arribaDer]
				
				vectorEscaleraColision.append(rayIzq.get_collider())
			
			elif sobreEscalera and evaluarEscaleraAbajo and not existeEscaleraExcepcion(rayIzq.get_collider()):
				evaluarEscaleraAbajo = false
				bajarEscaleraDoble = true
				limites.x = rayIzq.get_collider().limiteSuperior
				limites.y = rayIzq.get_collider().limiteInferior 
				centroEjeEscalera = rayDer.get_collider().centro
				vectorEscaleraColision.append(rayIzq.get_collider())
				# estoy arriba
				if centroEjeEscalera.y-diff > eje.get_global_pos().y:
					# print("estoy arriba en: "+rayIzq.get_collider().get_name())
					arribaEscalera = true
					dirMovimiento = [rayIzq.get_collider().arribaIzq, rayIzq.get_collider().arribaDer]
					dirMovimientoAux= [rayIzq.get_collider().abajoIzq, rayIzq.get_collider().abajoDer]
				# estoy abajo
			
				elif centroEjeEscalera.y-diff <= eje.get_global_pos().y:
					# print("estoy abajo en: "+rayIzq.get_collider().get_name())
					abajoEscalera = true
					dirMovimiento = [rayIzq.get_collider().abajoIzq, rayIzq.get_collider().abajoDer]
					dirMovimientoAux= [rayIzq.get_collider().arribaIzq, rayIzq.get_collider().arribaDer]
					agregarEscaleraExcepcion(rayIzq.get_collider())
				
	else:
		if sobreEscalera and not evaluarEscaleraAbajo:
			resetearVariables()
		
		elif evaluarEscaleraAbajo and vectorEscaleraExcepcion.size() > 0:
			rayIzq.remove_exception(vectorEscaleraExcepcion[0])
			rayDer.remove_exception(vectorEscaleraExcepcion[0])
			vectorEscaleraExcepcion.clear()
			evaluarEscaleraAbajo = false
			resetearVariablesActualizarSuelo()

func resetearVariablesActualizarSuelo():
	sobreEscalera = false
	arribaEscalera = false
	abajoEscalera = false 
	dirMovimiento = [true, true]
	dirMovimientoAux= [false, false]
	evaluarEscaleraAbajo = false
	bajarEscaleraDoble = false
	bajarEscaleraNormal = false
	subirEscaleraNormal = false
	if vectorEscaleraExcepcion.size() > 0:
		rayIzq.remove_exception(vectorEscaleraExcepcion[0])
		rayDer.remove_exception(vectorEscaleraExcepcion[0])
	vectorEscaleraExcepcion.clear()
	vectorEscaleraColision.clear()

func resetearVariables():
	limiteSuperiorEscalera = false
	limiteInferiorEscalera = false
	sobreEscalera = false
	arribaEscalera = false
	abajoEscalera = false 
	dirMovimiento = [true, true]
	dirMovimientoAux= [false, false]
	evaluarEscaleraAbajo = false
	bajarEscaleraDoble = false
	bajarEscaleraNormal = false
	subirEscaleraNormal = false
	if vectorEscaleraExcepcion.size() > 0:
		rayIzq.remove_exception(vectorEscaleraExcepcion[0])
		rayDer.remove_exception(vectorEscaleraExcepcion[0])
	vectorEscaleraExcepcion.clear()
	vectorEscaleraColision.clear()
#	print("afuera!")

func agregarEscaleraExcepcion(obj):
	var resultado = false
	if not existeEscaleraExcepcion(obj):
		vectorEscaleraExcepcion.append(obj)
		resultado = true
	return resultado

func existeEscaleraExcepcion(obj):
	var resultado = false
	for elemento in vectorEscaleraExcepcion:
		if elemento == obj:
			resultado = true
			break	
	return resultado

func existeEscaleraColision(obj):
	var resultado = false
	for elemento in vectorEscaleraColision:
		if elemento == obj:
			resultado = true
			break	
	return resultado