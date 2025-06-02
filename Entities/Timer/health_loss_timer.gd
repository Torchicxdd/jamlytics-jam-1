extends Timer

func _on_timeout() -> void:
	SignalBus.emit_signal("death")
