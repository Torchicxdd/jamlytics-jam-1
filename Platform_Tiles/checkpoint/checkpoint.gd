extends Area2D

@onready var sprite = $Sprite2D

var active := false

# preload the new image
var active_texture = preload("res://Platform_Tiles/checkpoint/images.steamusercontent - Copy.jpg")
var inactive_texture = preload("res://Platform_Tiles/checkpoint/images.steamusercontent.jpg")

func _on_body_entered(body):
	if body.name == "Player":
		if active:
				body.checkpoint = null
				print(body.checkpoint)
				sprite.texture = inactive_texture
				active = false
		else:
				body.checkpoint = global_position
				print(body.checkpoint)
				sprite.texture = active_texture
				active = true
