# NEVER USE PLAYER NODE'S METHODS
# ALWAYS USE METHODS LOCAL TO CHARCATERBODY2D OR RIGIDBODY2D

# Player bodies and terrain on physics layer 1
# Plug/sockets on physics layer 2

extends Node2D

# Constants
@export var speed: float = 450.0
@export var jump_power: float = 450.0
@export var max_vertical_velocity: float = 2250.0
@export var max_jump_time: float = 0.25
var impulse_strength: float = 15.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Character states
var is_character_mode = true
var is_swinging_mode = false
var is_jumping = false
var has_canceled_jump = false

# Camera
var camera_position = Vector2.ZERO

# Jumping constants
var previous_jump_time = Time.get_unix_time_from_system()
var time_between_jump

# Swinging position
var hook_position: Vector2
var socket_position: Vector2

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
		is_swinging_mode = false

func switch_to_swinging_mode():
	if is_character_mode:
		$RigidBody2D.linear_velocity = $CharacterBody2D.velocity
		$RigidBody2D.global_position = $CharacterBody2D.global_position
		
		set_body_state($CharacterBody2D, false, true, 0, 0)
		set_body_state($RigidBody2D, true, false, 1, 1)
		
		$RigidBody2D.freeze = false
		
		is_character_mode = false
		is_swinging_mode = true
		

func set_body_state(body: Node2D, visible: bool, disabled: bool, layer: int, mask: int) -> void:
	body.visible = visible
	body.get_node("CollisionShape2D").disabled = disabled
	body.collision_layer = layer
	body.collision_mask = mask

func _process(delta: float) -> void:
	if not is_jumping:
		previous_jump_time = Time.get_unix_time_from_system()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		hook_position = $CharacterBody2D.get_global_mouse_position()
		$RigidBody2D/RayCast2D.target_position = $RigidBody2D.to_local(hook_position)
		$RigidBody2D/RayCast2D.force_raycast_update()
		if $RigidBody2D/RayCast2D.is_colliding():
			var collider = $RigidBody2D/RayCast2D.get_collider()
			if collider.is_in_group("Hookable") and collider is StaticBody2D:
				socket_position = collider.global_position
				$RigidBody2D.linear_velocity += Vector2(-500, 0)
				switch_to_swinging_mode()
	elif Input.is_action_just_released("left_click"):
		switch_to_character_mode()
	
	
	if is_swinging_mode:
		$RigidBody2D/RayCast2D.target_position = $RigidBody2D.to_local(hook_position)
		$RigidBody2D/RayCast2D.force_raycast_update()
		swing_handler()
	else:
		$RigidBody2D/Tail.set_point_position(1, Vector2.ZERO)
		$RigidBody2D/Plug.position = Vector2.ZERO
		switch_to_character_mode()
	
	if is_character_mode:
		character_process_handler(delta)
	elif is_swinging_mode:
		swinging_process_handler(delta)
	
	# Place camera according to current body
	$Camera2D.global_position = $Camera2D.global_position.lerp(camera_position, 0.1)
	handle_animations()
	

func character_process_handler(delta):
	$RigidBody2D.global_position = $CharacterBody2D.global_position
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

func swing_handler():
	var local_socket_position = $RigidBody2D.to_local(socket_position)
	$RigidBody2D/Tail.set_point_position(1, local_socket_position)
	$RigidBody2D/Plug.position = local_socket_position
	$PinJoint2D.position = local_socket_position

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
	$CharacterBody2D.global_position = $RigidBody2D.global_position
	camera_position = $RigidBody2D.global_position

func handle_animations():
	if is_character_mode:
		if $CharacterBody2D.velocity.x > 0:
			$CharacterBody2D/AnimatedSprite2D.play("run_right")
		elif $CharacterBody2D.velocity.x < 0:
			$CharacterBody2D/AnimatedSprite2D.play("run_left")
		else:
			$CharacterBody2D/AnimatedSprite2D.stop()
