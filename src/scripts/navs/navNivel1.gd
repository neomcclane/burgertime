extends Navigation2D

const VELOCIDAD = 200.0

onready var enemigo = get_node("enemigo")

var inicio = Vector2()
var fin = Vector2()
var camino = []

func _ready():
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.pressed:
		print("click!")
		inicio = enemigo.get_pos()
		fin = event.pos - get_pos()
		generarCamino()

func _process(delta):
	if camino.size() > 1:
		var andar = VELOCIDAD*delta
		while andar > 0 and camino.size() >= 2:
			var pInicio = camino[camino.size()-1]
			var pFin = camino[camino.size()-2]
			var d = pInicio.distance_to(pFin)
			if d <= andar:
				camino.remove(camino.size()-1)
				andar -= d
			else:
				camino[camino.size()-1] = pInicio.linear_interpolate(pFin, andar/d)
				andar = 0
		
		enemigo.set_pos(Vector2(camino[camino.size()-1].x, camino[camino.size()-1].y + 100))
		
		if camino.size() < 2:
			camino = []
			set_process(false)
		
	else:
		set_process(false)

func generarCamino():
	var p = get_simple_path(inicio, fin, true)
	camino = Array(p)
	camino.invert()
	set_process(true)