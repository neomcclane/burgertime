extends Area2D

onready var sprite = get_node("sprite")

var posX = 0
var posY = 0
var ancho = 8
var largo = 32
var diff = 1
var abajo = false

func _ready():
	add_to_group("elemento")
	sprite.set_region_rect(Rect2(Vector2(posX, posY), Vector2(ancho, largo)))

func _on_elemento_area_enter( area ):
	if not abajo and area.is_in_group("player"):
		abajo = true
		set_pos(Vector2(get_pos().x, get_pos().y+diff))
