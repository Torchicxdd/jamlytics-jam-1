extends Node2D

@export var rest_length = 2.0
@export var stiffness = 10.0
@export var damping = 2.0

@onready var player = get_parent() as CharacterBody2D
@onready var ray = $RayCast2D
@onready var tail = $Tail as Line2D

var is_tail_thrown = false
var target: Vector2

func _process(delta):
	ray.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("left_click"):
		connect_tail()
	if Input.is_action_just_released("left_click"):
		disconnect_tail()
		
	if is_tail_thrown:
		handle_grapple(delta)
	
func connect_tail():
	if ray.is_colliding():
		is_tail_thrown = true
		target = ray.get_collision_point()

func disconnect_tail():
	is_tail_thrown = false
	
func handle_grapple(delta):
	var target_dir = player.get_global_position().direction_to(target)
	var target_dist = player.get_global_position().distance_to(target)
	
	var displacement = target_dist - rest_length
	var force = Vector2.ZERO
	
	if displacement > 0:
		var spring_force_mag = stiffness * displacement
		var spring_force = target_dir * spring_force_mag
		
		var vel_dot = player.get_velocity().dot(target_dir)
		var damping = -damping * vel_dot * target_dir
		
		force = spring_force + damping
		
	player.velocity += force * delta
	update_tail()
	
func update_tail():
	tail.set_point_position(1, to_local(target))
