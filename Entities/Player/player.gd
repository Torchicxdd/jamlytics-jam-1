# Player bodies and terrain on physics layer 1
# Plug/sockets on physics layer 2

extends CharacterBody2D

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

# Jumping constants
var previous_jump_time = Time.get_unix_time_from_system()
var time_between_jump

# Swinging values
var global_hook_position: Vector2
var global_socket_position: Vector2
var swing_angle: float
var swing_length: float
var angular_velocity: float = 0.0

func _process(delta: float) -> void:
	if not is_jumping:
		previous_jump_time = Time.get_unix_time_from_system()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		global_hook_position = get_global_mouse_position()
		$RayCast2D.target_position = to_local(global_hook_position)
		$RayCast2D.force_raycast_update()
		if $RayCast2D.is_colliding():
			var collider = $RayCast2D.get_collider()
			if collider.is_in_group("Hookable") and collider is StaticBody2D:
				global_socket_position = collider.global_position
				is_swinging_mode = true
				var swing_relative_character_position = global_position - global_socket_position
				swing_angle = atan2(swing_relative_character_position.x, swing_relative_character_position.y)
				swing_length = global_position.distance_to(global_socket_position)
				
	elif Input.is_action_just_released("left_click"):
		is_swinging_mode = false
	
	# Setting variables related to swinging and unswinging
	if is_swinging_mode:
		$RayCast2D.target_position = to_local(global_hook_position)
		$RayCast2D.force_raycast_update()
		swing_objects_handler()
		swinging_process_handler(delta)
		move_and_slide()
	else:
		$Tail.set_point_position(1, Vector2.ZERO)
		$Plug.position = Vector2.ZERO
		character_process_handler(delta)
	
	handle_animations()
	

func character_process_handler(delta):
	# Falling / jumping boolean setters
	if is_on_floor() or Input.is_action_just_released("move_up"):
		is_jumping = false
	if Time.get_unix_time_from_system() - previous_jump_time >= max_jump_time:
		has_canceled_jump = true
		is_jumping = false
	
	horizontal_movement_handler()
	vertical_movement_handler(delta)
	move_and_slide()

func swing_objects_handler():
	var local_socket_position = to_local(global_socket_position)
	$Tail.set_point_position(1, local_socket_position)
	$Plug.position = local_socket_position

func horizontal_movement_handler():
	var horizontal = Input.get_axis("move_left", "move_right")
	if horizontal:
		velocity.x = horizontal * speed
	else:           
		velocity.x = move_toward(velocity.x, 0, speed)
		

func vertical_movement_handler(delta):
	# First started jumping
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		is_jumping = true
		has_canceled_jump = false;
		
	if is_jumping:
		velocity.y = -(jump_power)
	else:
		# Handle gravity
		if velocity.y < max_vertical_velocity:
			velocity.y += gravity * delta
	if has_canceled_jump:
		velocity.y += lerp(0.0, -jump_power, 0.1)
		has_canceled_jump = false

func swinging_process_handler(delta):
	var swing_relative_character_position = global_position - global_socket_position
	
	# Apply existing velocity
	var tangent_dir = Vector2(cos(swing_angle), -sin(swing_angle))
	var tangential_speed = velocity.dot(tangent_dir)
	angular_velocity = tangential_speed / swing_length
	
	# Calculate new velocity
	var angular_acceleration = -(gravity / swing_length) * sin(swing_angle)
	angular_velocity += angular_acceleration * delta
	swing_angle += angular_velocity * delta
	velocity = Vector2(cos(swing_angle), -sin(swing_angle)) * swing_length * angular_velocity

func handle_animations():
	if is_character_mode:
		if velocity.x > 0:
			$AnimatedSprite2D.play("run_right")
		elif velocity.x < 0:
			$AnimatedSprite2D.play("run_left")
		else:
			$AnimatedSprite2D.stop()
