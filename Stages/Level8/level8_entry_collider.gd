extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.health_constant = 1
		Global.world.unload_level(5)
		Global.world.load_level(6)
		Global.world.load_level(7)
		Global.world.load_level(8)
