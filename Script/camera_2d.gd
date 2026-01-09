extends Camera2D

@onready var background_path: NodePath = "World/Background"

func _ready():
	var bg = get_node_or_null(background_path)
	if bg and bg is Sprite2D and bg.texure:
		var tex_size = bg.texture.get.size() * bg.scale
		limit_left = int(-tex_size.x / 2)
		limit_right = int(tex_size.x / 2)
		limit_top = int(-tex_size.y / 2)
		limit_bottom = int(tex_size.y / 2)
