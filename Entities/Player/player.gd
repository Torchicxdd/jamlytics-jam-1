extends Node2D

@export var speed = 10.0
@export var jump_power = 10.0
var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 0
var is_character_mode = true
var impulse_strength = 15.0

var pending_physics_mode = false
var pending_character_mode = false

var camera_position = Vector2.ZERO

func _ready() -> void:
	set_body_state($RigidBody2D, false, true, 0, 0)
	$RigidBody2D.freeze = true
	
	set_body_state($CharacterBody2D, true, false, 1, 1)

func switch_to_character_mode():
	if not is_character_mode:
		$CharacterBody2D.velocity = $RigidBody2D.linear_velocity
		$CharacterBody2D.global_position = $RigidBody2D.global_position
		
		set_body_state($RigidBody2D, false, true, 0, 0)
		$RigidBody2D.freeze = true
		
		set_body_state($CharacterBody2D, true, false, 1, 1)
		
		is_character_mode = true

func switch_to_physics_mode():
	if is_character_mode:
		$RigidBody2D.linear_velocity = $CharacterBody2D.velocity
		$RigidBody2D.global_position = $CharacterBody2D.global_position
		
		set_body_state($CharacterBody2D, false, true, 0, 0)
		set_body_state($RigidBody2D, true, false, 1, 1)
		
		$RigidBody2D.freeze = false
		
		is_character_mode = false

func set_body_state(body: Node2D, visible: bool, disabled: bool, layer: int, mask: int) -> void:
	body.visible = visible
	body.get_node("CollisionShape2D").disabled = disabled
	body.collision_layer = layer
	body.collision_mask = mask

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		pending_physics_mode = true
	elif event.is_action_released("left_click"):
		pending_character_mode = true

func _physics_process(delta: float) -> void:
	if pending_physics_mode:
		switch_to_physics_mode()
		pending_physics_mode = false
	elif pending_character_mode:
		switch_to_character_mode()
		pending_character_mode = false
	
	if is_character_mode:
		camera_position = $CharacterBody2D.global_position
		direction = Input.get_axis("move_left", "move_right")
		if direction:
			$CharacterBody2D.velocity.x = direction * speed * speed_multiplier
		else:           
			$CharacterBody2D.velocity.x = move_toward($CharacterBody2D.velocity.x, 0, speed * speed_multiplier)
		$CharacterBody2D.move_and_slide()
	else:
		camera_position = $RigidBody2D.global_position
	
	# Place camera according to current body
	$Camera2D.global_position = $Camera2D.global_position.lerp(camera_position, 0.1)
	handle_animations()
	
func handle_animations():
	if is_character_mode:
		if $CharacterBody2D.velocity.x > 0:
			$CharacterBody2D/AnimatedSprite2D.play("run_right")
		elif $CharacterBody2D.velocity.x < 0:
			$CharacterBody2D/AnimatedSprite2D.play("run_left")
		else:
			$CharacterBody2D/AnimatedSprite2D.stop()
