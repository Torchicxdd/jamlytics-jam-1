# Player bodies and terrain on physics layer 1
# Plug/sockets on physics layer 2

extends CharacterBody2D

# Constantsdadadwadawdadwa
@export var speed: float = 450.0
@export var jump_power: float = 1200.0
@export var charge_jump_power: float = 1200.0
@export var charge_dash_power: float = 1
@export var max_charge_dash_power: float = 3.5
@export var max_charge_jump_power: float = 2000.0
@export var max_charge_time: float = 1.0
@export var swing_gravitational_multiplier: float = 2
@export var jump_buffer_time: float = 0.1
@export var coyote_time: float = 0.1

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Health bar
var health: int = 6
@export var max_health: int = 6
var health_list: Array[TextureRect]

# Character states
var is_swinging = false
var is_jumping = false
var is_charging = false
var is_charge_jumping = false
var is_charge_dashing = false
var is_on_platform = false
var platform_speed = null
var checkpoint = null
var jump_buffer = false
var jump_available: bool = true

# Charging constants
var current_charge_time = 0.0

# Swinging values
var global_hook_position: Vector2
var global_socket_position: Vector2
var swing_angle: float
var swing_length: float
var angular_velocity: float = 0.0
var prev_angular_velocity: float = 0
var swing_direction_initialized: bool = false
@export var swing_energy_loss: float = 0.99
@export var detach_swing_boost: Vector2 = Vector2(450, 0)
var used_socket: Array[Node] = []

# Coyote timer
@onready var coyote_timer : Timer = $CoyoteTimer

func _ready() -> void:
	# Initialize health bar
	var health_bar = $Camera2D/HealthBar
	for i in range(health):
		health_list.append(health_bar.get_node("Health" + str(i + 1)))
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		if not is_on_floor():
			global_hook_position = get_global_mouse_position()
			$RayCast2D.target_position = to_local(global_hook_position)
			$RayCast2D.force_raycast_update()
			if $RayCast2D.is_colliding():
				var collider = $RayCast2D.get_collider()
				if collider.is_in_group("Hookable") and collider is Socket:
					var socket = collider as Socket
					if socket.is_hookable:
						global_socket_position = collider.global_position
						is_swinging = true
						is_charge_dashing = false
						is_charge_jumping = false
						var swing_relative_character_position = global_position - global_socket_position
						swing_angle = atan2(swing_relative_character_position.x, swing_relative_character_position.y)
						swing_length = global_position.distance_to(global_socket_position)
						# If the socket has not already been used, add it to the used sockets and heal the player
						if not collider in used_socket and health < max_health:
							used_socket.append(collider)
							heal(1)
				
	elif Input.is_action_just_released("left_click"):
		is_swinging = false
		swing_direction_initialized = false
	
	handle_charge_inputs(delta)
	
	# Setting variables related to swinging and unswinging
	if is_swinging:
		$RayCast2D.target_position = to_local(global_hook_position)
		$RayCast2D.force_raycast_update()
		var local_socket_position = to_local(global_socket_position)
		$Tail.set_point_position(1, local_socket_position)
		swinging_process_handler(delta)
	else:
		$Tail.set_point_position(1, Vector2.ZERO)
		character_process_handler(delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		# start coyote time
		if jump_available:
			if coyote_timer.is_stopped():
				coyote_timer.start(coyote_time)
			#get_tree().create_timer(coyote_time).timeout.connect(_on_coyote_timer_timeout)

	if is_on_platform:
		global_position += platform_speed
	
	move_and_slide()
	handle_animations()

func character_process_handler(delta):
	# Falling / jumping boolean setters
	if is_on_floor():
		jump_available = true
		coyote_timer.stop()
		is_jumping = false
		is_charge_jumping = false
		is_charge_dashing = false
		# If the jump was buffered, jump immediately
		if jump_buffer:
			jump()
			jump_buffer = false
	
	horizontal_movement_handler()
	vertical_movement_handler(delta)

func swing_objects_handler():
	var local_socket_position = to_local(global_socket_position)
	$Tail.set_point_position(1, local_socket_position)
	$Plug.position = local_socket_position

func horizontal_movement_handler():
	var horizontal = Input.get_axis("move_left", "move_right")
	if horizontal:
		velocity.x = horizontal * speed
		if is_charge_dashing:
			velocity.x = horizontal * speed * charge_dash_power
			
	else:           
		velocity.x = move_toward(velocity.x, 0, speed)

func vertical_movement_handler(delta):
	# First started jumping
	if Input.is_action_just_pressed("jump"):
		if jump_available:
			jump()
		else:
			# Jump buffer logic
			jump_buffer = true
			get_tree().create_timer(jump_buffer_time).timeout.connect(_on_jump_buffer_timer_timeout)
	
func handle_charge_inputs(delta):
	if Input.is_action_just_released("charge") and is_on_floor() and not is_charge_jumping:
		is_jumping = false
		is_charge_jumping = true
		is_charge_dashing = false
		is_swinging = false
		velocity.y = -(charge_jump_power)
		take_damage(1)
		
	if Input.is_action_just_released("charge") and not is_on_floor() and not is_charge_dashing:
		is_jumping = false
		is_charge_jumping = false
		is_charge_dashing = true
		is_swinging = false
		velocity.y = -(charge_jump_power/2)
		take_damage(1)
		
	# Handle charging jumps
	if Input.is_action_pressed("charge"):
		is_charging = true
	else:
		is_charging = false
		current_charge_time = 0.0
		
	if is_charging:
		current_charge_time += delta
		if current_charge_time >= max_charge_time:
			current_charge_time = max_charge_time
		charge_jump_power = lerp(900.0, max_charge_jump_power, current_charge_time / max_charge_time)
		charge_dash_power = lerp(2.0, max_charge_dash_power, current_charge_time / max_charge_time)
	
	$Camera2D/ChargeBar.value = current_charge_time / max_charge_time
	
func swinging_process_handler(delta):
	var swing_relative_character_position = global_position - global_socket_position
	
	#Apply existing velocity
	var tangent_dir = Vector2(cos(swing_angle), -sin(swing_angle))
	var tangential_speed = velocity.dot(tangent_dir)
	angular_velocity = tangential_speed / swing_length
	prev_angular_velocity = angular_velocity
	
	# Calculate new velocity
	var angular_acceleration = -(gravity * swing_gravitational_multiplier / swing_length) * sin(swing_angle)
	var applied_angular_velocity = angular_acceleration * delta
	
	if sign(prev_angular_velocity) == sign(applied_angular_velocity):
		# Swinging in the same direction for the first time
		swing_direction_initialized = true
	
	# Apply new calculated velocity
	angular_velocity += applied_angular_velocity
	angular_velocity *= swing_energy_loss
	 
	swing_angle += angular_velocity * delta
	velocity = Vector2(cos(swing_angle), -sin(swing_angle)) * swing_length * angular_velocity
	
	# Keep the new velocity tangential.
	# Was creating inwards movement creep without
	var tangent = Vector2(-swing_relative_character_position.y, swing_relative_character_position.x).normalized()
	velocity = velocity.dot(tangent) * tangent
	velocity.y -= gravity * delta
	
	# Check to see when player will reach max opposite direction of swing
	if sign(prev_angular_velocity) != sign(angular_velocity) and swing_direction_initialized == true:
		is_swinging = false
		swing_direction_initialized = false

func handle_animations():
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = true
		$ObstacleCollision/CollisionPolygon2D.scale.x = -1
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = false
		$ObstacleCollision/CollisionPolygon2D.scale.x = 1
		
	if not is_on_floor():
		if velocity.y < 0:
			$AnimationPlayer.play("jump")
		elif velocity.y >= 0:
			$AnimationPlayer.play("fall")
	elif velocity.x != 0:
		$AnimationPlayer.play("run")
	else:
		$AnimationPlayer.play("idle")

func jump() -> void:
	is_jumping = true
	is_charge_jumping = false
	is_charge_dashing = false
	is_swinging = false
	jump_available = false
	velocity.y = -(jump_power)

func take_damage(damage: int) -> void:
	health -= damage
	update_health_bar()
	if health <= 0:
		respawn()
		

func heal(damage: int) -> void:
	health += damage
	if health > 6:
		health = 6

	update_health_bar()

func update_health_bar() -> void:
	for i in range(health_list.size()):
		health_list[i].visible = i < health

func respawn():
	if checkpoint:
		global_position = checkpoint
		global_position.x += 150
	else:
		global_position = Vector2(-1216, -702)
	
	reset_values()
	heal(6)

# called by whatever timer that is in the stage that the player is in
# make sure to set up the signal per stage to whatver time u want
func _on_health_loss_timer_timeout():
	take_damage(1)

func _on_jump_buffer_timer_timeout() -> void:
	jump_buffer = false

func _on_coyote_timer_timeout() -> void:
	jump_available = false

func reset_values():
	health = 6
	current_charge_time = 0.0
	is_swinging = false
	is_jumping = false
	is_charging = false
	is_charge_jumping = false
	is_charge_dashing = false
	swing_direction_initialized = false
	jump_buffer = false
	used_socket.clear()
	update_health_bar()
	$Camera2D/ChargeBar.value = 0.0
