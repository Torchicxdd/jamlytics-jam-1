extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.health_constant = 10
		Global.world.load_level(0, Vector2(-15120, 1280))
		Global.world.load_level(2, Vector2(4080, -1664))
