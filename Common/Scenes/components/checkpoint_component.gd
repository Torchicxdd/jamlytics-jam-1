extends Node2D
class_name CheckpointComponent

func _on_body_entered(body: Node2D) -> void:
	SignalBus.emit_signal("set_checkpoint", global_position)
