extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.health_constant = 10
		Global.world.unload_level(3)
		Global.world.load_level(4)
		Global.world.load_level(5)
		Global.world.load_level(6)
		Global.world.load_level(7)
