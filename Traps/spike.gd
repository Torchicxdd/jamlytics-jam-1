extends Area2D

func _on_spike_body_entered(body):
	print("Spike touched by:", body.name)
	if body.name == "Player":
		body.respawn()
