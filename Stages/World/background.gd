extends Sprite2D

var camera: Camera2D

func _ready() -> void:
	camera = get_viewport().get_camera_2d()
	
func _process(delta: float) -> void:
	if camera:
		var texture_size = texture.get_size()
		var viewport_size = get_viewport_rect().size
		var zoom = camera.zoom
		var viewport_size_zoom = viewport_size / zoom
		var calculated_scale = viewport_size_zoom / texture_size
		scale = calculated_scale
