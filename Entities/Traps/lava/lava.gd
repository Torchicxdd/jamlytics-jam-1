extends Area2D

@export var damage := 1

func player_hit(body):
	if body.name == "Player":
		SignalBus.emit_signal("death")
