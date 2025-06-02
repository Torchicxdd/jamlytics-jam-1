extends Control

var is_paused = false
var is_showing_dialog = false

func _ready() -> void:
	visible = false
	SignalBus.connect("display_dialog", Callable(self, "_on_displaying_dialog"))
	SignalBus.connect("dialog_finished", Callable(self, "_on_dialog_finished"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not is_showing_dialog:
		is_paused = !(is_paused)
		get_tree().paused = is_paused
		visible = is_paused

func _on_displaying_dialog(text: String):
	is_showing_dialog = true
	
func _on_dialog_finished():
	is_showing_dialog = false
