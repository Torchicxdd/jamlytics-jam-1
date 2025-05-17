extends CharacterBody2D

@export var speed = 400
var input_handler = InputHandler.new()

var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	move_handler(delta)
	handle_animations()

func move_handler(delta):
	velocity = input_handler.get_normalized_input_direction() * speed
	position += velocity * delta

func handle_animations():
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
