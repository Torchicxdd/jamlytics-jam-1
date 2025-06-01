class_name Socket extends Node2D

var is_hookable = false
var has_healed = false
var is_swinging = false
var heal_amount = 1

func _ready() -> void:
	SignalBus.connect("swinging", Callable(self, "_on_swing"))
	SignalBus.connect("death", Callable(self, "_on_death"))
	SignalBus.connect("has_stopped_swinging", Callable(self, "_on_released"))

func _on_area_2d_body_entered(body: Node2D) -> void:
	is_hookable = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	is_hookable = false

func _on_swing():
	if not has_healed and is_swinging:
		SignalBus.emit_signal("heal_player", heal_amount)
		has_healed = true

func _on_death():
	has_healed = false

func _on_released():
	is_swinging = false
