extends Area2D


func _on_body_entered(body: Node2D) -> void:
	SignalBus.emit_signal("game_end")
