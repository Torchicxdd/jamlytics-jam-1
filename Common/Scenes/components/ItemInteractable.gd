extends Area2D

@export var dialog_key: String = ""
var is_area_active = false
var is_dialog_finished = false

func _ready() -> void:
	SignalBus.connect("dialog_finished", Callable(self, "on_dialog_finished"))

func _input(event: InputEvent) -> void:
	if is_area_active and not is_dialog_finished and event.is_action_pressed("interact"):
		SignalBus.emit_signal("advance_dialog")

func _on_body_entered(body: Node2D) -> void:
	is_area_active = true
	is_dialog_finished = false
	SignalBus.emit_signal("display_dialog", dialog_key)
	
func _on_body_exited(body: Node2D) -> void:
	is_area_active = false
	is_dialog_finished = false

func on_dialog_finished():
	is_dialog_finished = true
