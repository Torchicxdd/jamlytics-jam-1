extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.health_constant = 11
		Global.world.load_level(3, Vector2(1216, -3648))
