extends Area2D

@export var collision: CollisionShape2D

func _on_body_entered(body: Node2D) -> void:
	SignalBus.emit_signal("stop_level_timer")
