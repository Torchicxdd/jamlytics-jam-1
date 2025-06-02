extends Area2D

@export var collision: CollisionShape2D
@export var timer: Timer
var is_started = false

func _ready():
	SignalBus.connect("death", Callable(self, "_on_death"))
	SignalBus.connect("stop_level_timer", Callable(self, "_on_stop_timer"))

func _on_body_entered(body: Node2D) -> void:
	if not is_started:
		is_started = true
		timer.start()
		SignalBus.emit_signal("start_level_timer", timer)

func _on_death():
	timer.stop()
	is_started = false
	SignalBus.emit_signal("stop_level_timer")
	
func _on_stop_timer():
	timer.stop()
	is_started = false
