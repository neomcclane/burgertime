extends Node2D

export var azul = true

onready var sprite = get_node("sprite") 

func _ready():
	if not azul:
		sprite.set_region_rect(Rect2(Vector2(64, 0), Vector2(32, 32)))
