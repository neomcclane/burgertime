extends Panel

onready var viewport = get_node("Viewport")
#onready var sprite = get_node("sprite")

func _ready():
	var text = viewport.get_render_target_texture()
#	sprite.set_texture(text)