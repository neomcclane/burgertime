extends Area2D

onready var sprite = get_node("sprite")
onready var animaciones = get_node("animaciones")
onready var rayIzq = get_node("rayIzq")
onready var rayDer = get_node("rayDer")
onready var eje = get_node("eje")
onready var eje_particulas = get_node("eje_particulas")
onready var pimienta = get_node("pimienta")

export var verEjesParticulas = false

var enemigos = []
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

var banderaCambio = false
var diffPimienta = 8
var emitiendo = false
var tiempoEmitiendo = 0

var muerte = false
var tiempoMuerte = 0

func _draw():
	if verEjesParticulas:
		draw_line(Vector2(eje_particulas.get_pos().x, eje_particulas.get_pos().y+10), Vector2(eje_particulas.get_pos().x, eje_particulas.get_pos().y-10), Color(0, 1, 0, 1))
		draw_line(Vector2(eje_particulas.get_pos().x+10, eje_particulas.get_pos().y), Vector2(eje_particulas.get_pos().x-10, eje_particulas.get_pos().y), Color(1, 0, 0, 1))

func _ready():
	for ene in get_parent().get_node("enemigos").get_children():
		enemigos.append(ene)
		rayIzq.add_exception(ene)
		rayDer.add_exception(ene)

	pimienta.set_z(150)
	if izquierda:
		eje_particulas.set_pos(Vector2(-8, 0))
	else:
		eje_particulas.set_pos(Vector2(8, 0))
	pimienta.set_pos(eje_particulas.get_pos())
	update()	

	set_z(100)
	if get_parent().get_node("alimentos"):
		for alimento in get_parent().get_node("alimentos").get_children():
			rayIzq.add_exception(alimento)
			rayDer.add_exception(alimento)
			for elemento in alimento.get_children():
				rayIzq.add_exception(elemento)
				rayDer.add_exception(elemento)
				
	add_to_group("player")
	rayIzq.add_exception(self)
	rayDer.add_exception(self)

	set_fixed_process(true)
	set_process_input(true)

func _input(event):
	if not muerte and event.type == InputEvent.KEY:
		if limiteInferiorEscalera and event.scancode == KEY_UP and event.pressed:
			resetearVariablesActualizarSuelo()
		elif limiteInferiorEscalera and event.scancode == KEY_DOWN and not event.pressed: # == false
			resetearVariablesActualizarSuelo()
		elif limiteSuperiorEscalera and event.scancode == KEY_DOWN and event.pressed:
			resetearVariablesActualizarSuelo()
		elif limiteSuperiorEscalera and event.scancode == KEY_UP and not event.pressed: # == false
			resetearVariablesActualizarSuelo()
		elif not emitiendo and global.NUM_PIMIENTA > 0 and not pimienta.get_node("particulas").is_emitting() and event.scancode == KEY_SPACE and not event.pressed:
			global.NUM_PIMIENTA -= 1
			emitiendo = true
			# arriba
			if eje_particulas.get_pos().x == 0 and eje_particulas.get_pos().y == -diffPimienta:
				pimienta.get_node("particulas").set_param(0, 90)
			# abajo
			elif eje_particulas.get_pos().x == 0 and eje_particulas.get_pos().y == diffPimienta:
				pimienta.get_node("particulas").set_param(0, 270)
			# izquierda
			elif eje_particulas.get_pos().y == 0 and eje_particulas.get_pos().x == -diffPimienta:
				pimienta.get_node("particulas").set_param(0, 180)
			# derecha
			elif eje_particulas.get_pos().y == 0 and eje_particulas.get_pos().x == diffPimienta:
				pimienta.get_node("particulas").set_param(0, 0)
				
			pimienta.get_node("particulas").set_emitting(true)

func _fixed_process(delta):
	if not pimienta.get_node("particulas").is_emitting():
		movimiento(delta)
	animacion()
	colisionesAbajo()

	if emitiendo and not global.EMITIENDO_PIMIENTA and tiempoEmitiendo > 0.4:
		emitiendo = false
		tiempoEmitiendo = 0
	elif emitiendo and global.EMITIENDO_PIMIENTA and tiempoEmitiendo <= 0.4:
		tiempoEmitiendo += 1*delta

	if global.EMITIENDO_PIMIENTA != pimienta.get_node("particulas").is_emitting():
		global.EMITIENDO_PIMIENTA = pimienta.get_node("particulas").is_emitting()

	if muerte and tiempoMuerte > 0.4:
		if global.NUM_VIDA > 0:
				global.NUM_VIDA -= 1
				get_tree().change_scene("res://src/niveles/ready.tscn")
		else:
			global.GAME_OVER = true
			get_tree().change_scene("res://src/niveles/ready.tscn")
	elif muerte and tiempoMuerte <= 0.4:
		tiempoMuerte += 1*delta
	
func movimiento(delta):
	anima1 = anima0
	posActual = get_pos()

	if not muerte and movHorizontal and dirMovimiento[0] and Input.is_action_pressed("tecla_izq"):
		izquierda = true
		direccion = Vector2(-1, 0)
		eje_particulas.set_pos(Vector2(-diffPimienta, 0))
		update()
	
	elif not muerte and movHorizontal and dirMovimiento[1] and Input.is_action_pressed("tecla_der"):
		izquierda = false
		direccion = Vector2(1, 0)
		eje_particulas.set_pos(Vector2(diffPimienta, 0))
		update()
	
	elif not muerte and eje_particulas.get_pos().y != diffPimienta and Input.is_action_pressed("tecla_abajo"):
		eje_particulas.set_pos(Vector2(0, diffPimienta))
		update()
	
	elif not muerte and eje_particulas.get_pos().y != -diffPimienta and Input.is_action_pressed("tecla_arriba"):
		eje_particulas.set_pos(Vector2(0, -diffPimienta))
		update()
	
	else:
		direccion.x = 0
	pimienta.set_pos(eje_particulas.get_pos())

	#------------------------------------------
	#****************************************************
	#****************************************************
	if not muerte and abajoEscalera and vectorEscaleraColision.size() > 0 and Input.is_action_pressed("tecla_abajo"):
		for elemento in vectorEscaleraColision:
			vectorEscaleraExcepcion.append(elemento)
		vectorEscaleraColision.clear()
		
		rayIzq.add_exception(vectorEscaleraExcepcion[0])
		rayDer.add_exception(vectorEscaleraExcepcion[0])
		evaluarEscaleraAbajo = true
	#****************************************************
	#****************************************************
	
	elif not muerte and abajoEscalera and  vectorEscaleraColision.size() > 0 and Input.is_action_pressed("tecla_arriba"):
		subirEscaleraNormal = true
	
	elif not muerte and arribaEscalera and not bajarEscaleraNormal and not teclaAbajoEscaleraNormal and vectorEscaleraColision.size() > 0 and Input.is_action_pressed("tecla_abajo"):
		bajarEscaleraNormal = true
	
	elif not muerte and bajarEscaleraNormal and Input.is_action_pressed("tecla_arriba"):
		bajarEscaleraNormal = false
		subirEscaleraNormal = true

	elif not muerte and subirEscaleraNormal and Input.is_action_pressed("tecla_abajo"):
		bajarEscaleraNormal = true
		subirEscaleraNormal = false

	elif not muerte and bajarEscaleraDoble and Input.is_action_pressed("tecla_arriba"):
		bajarEscaleraDoble = false
		subirEscaleraNormal = true
	
	if not muerte and limites.y > eje.get_global_pos().y and (bajarEscaleraDoble or bajarEscaleraNormal) and Input.is_action_pressed("tecla_abajo"):
		direccion = Vector2(0, 1)
		movHorizontal = false
		arribaEscalera = false
		limiteInferiorEscalera = false
		limiteSuperiorEscalera = false
		
	#limite inferior
	elif not muerte and limites.y <= eje.get_global_pos().y and (bajarEscaleraDoble or bajarEscaleraNormal) and Input.is_action_pressed("tecla_abajo"):
		direccion.y = 0
		movHorizontal = true
		bajarEscaleraNormal = false
		dirMovimiento = dirMovimientoAux
		limiteInferiorEscalera = true
		
	elif not muerte and limites.x < eje.get_global_pos().y and subirEscaleraNormal and Input.is_action_pressed("tecla_arriba"):
		direccion = Vector2(0, -1)
		movHorizontal = false
		limiteInferiorEscalera = false
		limiteSuperiorEscalera = false
		
	#limite superior
	elif not muerte and limites.x >= eje.get_global_pos().y and subirEscaleraNormal and Input.is_action_pressed("tecla_arriba"):
		movHorizontal = true
		direccion.y = 0
		dirMovimiento = dirMovimientoAux
		limiteSuperiorEscalera = true
		
	elif not limiteSuperiorEscalera and limites.x+diff >= eje.get_global_pos().y and sobreEscalera:
		limiteSuperiorEscalera = true
		
	elif not  limiteInferiorEscalera and limites.y-diff <= eje.get_global_pos().y and sobreEscalera:
		limiteInferiorEscalera = true
		

	else:
		direccion.y = 0
	#------------------------------------------
	
	if not muerte and banderaCambio and (limiteInferiorEscalera or limiteSuperiorEscalera) and direccion.x == 0:
		anima0 = "animaEscaleraIdle"
	
	elif not muerte and banderaCambio and (bajarEscaleraDoble or bajarEscaleraNormal or subirEscaleraNormal) and direccion.y != 0:
		anima0 = "animaEscalera"
	
	elif not muerte and banderaCambio and (bajarEscaleraDoble or bajarEscaleraNormal or subirEscaleraNormal) and direccion.y == 0:
		if animaQuietoAux != anima0:
			randomize()
			anima0 = animaQuieto[randi()%2+0]
			animaQuietoAux = anima0

	elif not muerte and not banderaCambio and movHorizontal and direccion.x != 0:
		anima0 = "caminar"
	
	elif not muerte and not banderaCambio:
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
				banderaCambio = true
				sobreEscalera = true
				limites.x = rayIzq.get_collider().limiteSuperior
				limites.y = rayIzq.get_collider().limiteInferior 
				centroEjeEscalera = rayDer.get_collider().centro
				
				# estoy arriba
				if centroEjeEscalera.y-diff > eje.get_global_pos().y:
					if enemigos.size() > 0:
						global.LISTA_POSICIONES.append(Vector2(rayIzq.get_collider().posicion.get_global_pos().x, rayIzq.get_collider().posicion.get_global_pos().y - (rayIzq.get_collider().filas*rayIzq.get_collider().ancho)))
						for n in enemigos:
							n.ejecutarBusqueda()
					
					arribaEscalera = true
					dirMovimiento = [rayIzq.get_collider().arribaIzq, rayIzq.get_collider().arribaDer]
					dirMovimientoAux= [rayIzq.get_collider().abajoIzq, rayIzq.get_collider().abajoDer]
				# estoy abajo
				elif centroEjeEscalera.y-diff <= eje.get_global_pos().y:
					if enemigos.size() > 0:
						global.LISTA_POSICIONES.append(rayIzq.get_collider().posicion.get_global_pos())
						for n in enemigos:
							n.ejecutarBusqueda()
					
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
					arribaEscalera = true
					dirMovimiento = [rayIzq.get_collider().arribaIzq, rayIzq.get_collider().arribaDer]
					dirMovimientoAux= [rayIzq.get_collider().abajoIzq, rayIzq.get_collider().abajoDer]
				# estoy abajo
			
				elif centroEjeEscalera.y-diff <= eje.get_global_pos().y:
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
		else:
			banderaCambio = false

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
	sobreEscalera = false
	limiteSuperiorEscalera = false
	limiteInferiorEscalera = false
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

func _on_chef_area_enter( area ):
	if area.is_in_group("enemigos") and not area.detenido and not area.eliminado and not global.EMITIENDO_PIMIENTA:
		muerte = true
		if not muerte and banderaCambio and (bajarEscaleraDoble or bajarEscaleraNormal or subirEscaleraNormal) and direccion.y == 0:
			anima0 = animaQuieto[randi()%2+0]
		else:
			anima0 = "idle"
		animacion()
		