extends Node2D

@export var speed: float = 450.0
@export var jump_power: float = 450.0
@export var max_vertical_velocity: float = 3500.0
@export var max_jump_time: float = 0.25
var impulse_strength: float = 15.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_character_mode = true
var pending_physics_mode = false
var pending_character_mode = false
var is_jumping = false
var has_canceled_jump = false

var camera_position = Vector2.ZERO
var previous_jump_time = Time.get_unix_time_from_system()
var time_between_jump

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

func _process(delta: float) -> void:
	if not is_jumping:
		previous_jump_time = Time.get_unix_time_from_system()

func _physics_process(delta: float) -> void:
	if pending_physics_mode:
		switch_to_physics_mode()
		pending_physics_mode = false
	elif pending_character_mode:
		switch_to_character_mode()
		pending_character_mode = false
	
	if is_character_mode:
		character_process_handler(delta)
	else:
		swinging_process_handler(delta)
	
	# Place camera according to current body
	$Camera2D.global_position = $Camera2D.global_position.lerp(camera_position, 0.1)
	handle_animations()
	

func character_process_handler(delta):
	camera_position = $CharacterBody2D.global_position
	
	# Falling / jumping boolean setters
	if $CharacterBody2D.is_on_floor() or Input.is_action_just_released("move_up"):
		is_jumping = false
	if Time.get_unix_time_from_system() - previous_jump_time >= max_jump_time:
		has_canceled_jump = true
		is_jumping = false
	
	horizontal_movement_handler()
	vertical_movement_handler(delta)
	
	$CharacterBody2D.move_and_slide()

func horizontal_movement_handler():
	var horizontal = Input.get_axis("move_left", "move_right")
	if horizontal:
		$CharacterBody2D.velocity.x = horizontal * speed
	else:           
		$CharacterBody2D.velocity.x = move_toward($CharacterBody2D.velocity.x, 0, speed)

func vertical_movement_handler(delta):
	# First started jumping
	if Input.is_action_just_pressed("move_up") and $CharacterBody2D.is_on_floor():
		is_jumping = true
		has_canceled_jump = false;
		
	if is_jumping:
		$CharacterBody2D.velocity.y = -(jump_power)
	else:
		# Handle gravity
		if $CharacterBody2D.velocity.y < max_vertical_velocity:
			$CharacterBody2D.velocity.y += gravity * delta
	if has_canceled_jump:
		$CharacterBody2D.velocity.y += lerp(0.0, -jump_power, 0.1)
		has_canceled_jump = false

func swinging_process_handler(delta):
	camera_position = $RigidBody2D.global_position

func handle_animations():
	if is_character_mode:
		if $CharacterBody2D.velocity.x > 0:
			$CharacterBody2D/AnimatedSprite2D.play("run_right")
		elif $CharacterBody2D.velocity.x < 0:
			$CharacterBody2D/AnimatedSprite2D.play("run_left")
		else:
			$CharacterBody2D/AnimatedSprite2D.stop()
