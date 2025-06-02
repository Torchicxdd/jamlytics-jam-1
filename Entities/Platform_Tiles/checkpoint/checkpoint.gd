extends Area2D

@onready var sprite = $Sprite2D
@onready var sfx_checkpoint = $CheckpointSound

var active := false

# preload the new image
var active_texture = preload("res://Assets/station-active.png")
var inactive_texture = preload("res://Assets/station-inactive.png")

func _on_body_entered(body):
	if body.name == "Player":
		SignalBus.emit_signal("heal_player", body.health_constant - body.health)
		if not active:
			SignalBus.emit_signal("set_checkpoint", global_position)
			sprite.texture = active_texture
			active = true
			sfx_checkpoint.play()
