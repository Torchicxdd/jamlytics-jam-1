extends CharacterBody2D
class_name PlayerController

@export var speed = 10.0
@export var jump_power = 10.0

@onready var tailController = $TailController

var speed_multiplier = 30.0
var jump_multiplier = -30.0

func _input(event):
	# Handle jump.
	if event.is_action_pressed("move_up") and is_on_floor():
		velocity.y = jump_power * jump_multiplier

	# Handle jump down
	if event.is_action_pressed("move_down"):
		set_collision_mask_value(10, false)
	else:
		set_collision_mask_value(10, true)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed * speed_multiplier
	else:           
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)
		
	move_and_slide()
	handle_animations()

func handle_animations():
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
