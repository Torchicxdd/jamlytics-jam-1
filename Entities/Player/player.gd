extends CharacterBody2D

@export var speed = 400
var movement_direction = Vector2.ZERO
var input_handler = InputHandler.new()

var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	move_handler(delta)
	handle_animations()

func _input(event):
	if event.is_action("move_left"):
		if event.is_pressed() and not event.is_echo():
			movement_direction.x += -1
		elif not event.is_pressed():
			movement_direction.x += 1
	if event.is_action("move_right"):
		if event.is_pressed() and not event.is_echo():
			movement_direction.x += 1
		elif not event.is_pressed():
			movement_direction.x += -1
	if event.is_action("move_up"):
		if event.is_pressed() and not event.is_echo():
			movement_direction.y += -1
		elif not event.is_pressed():
			movement_direction.y += 1
	if event.is_action("move_down"):
		if event.is_pressed() and not event.is_echo():
			movement_direction.y += 1
		elif not event.is_pressed():
			movement_direction.x += -1

func move_handler(delta):
	velocity = movement_direction * speed
	position += velocity * delta

func handle_animations():
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
