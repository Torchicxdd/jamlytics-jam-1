extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.health_constant = 8
		Global.world.load_level(0)
		Global.world.load_level(1)
		Global.world.load_level(2)
