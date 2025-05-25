extends StaticBody2D
@onready var wall_ray := $WallRay
@export var is_moving := false
@export var move_distance := 100.0
@export var speed := 100.0
@export var range := 500.0
@export var horizontal := true

@onready var player_on_box = $Area2D

var direction := 1
var start_x := 0.0
var start_y := 0.0
var previous_position := Vector2.ZERO       # stores position from previous frame
var velocity := Vector2.ZERO                # velocity to pass to the player
var player_on_platform :Node = null

func update_raycast_direction():
	if horizontal:
		wall_ray.target_position  = Vector2(30 * direction, 0)
	else:
		wall_ray.target_position  = Vector2(0, 30 * direction)

func _ready():
	start_x = global_position.x
	start_y = global_position.y
	update_raycast_direction()

func _physics_process(delta):
	if is_moving:
		if horizontal:
			global_position.x += direction * speed * delta
			if global_position.x > start_x + range or global_position.x < start_x:
				direction *= -1  # reverse direction
				if player_on_platform:
					player_on_platform.platform_speed *= -1
				update_raycast_direction()
			if wall_ray.is_colliding():
				var collider = wall_ray.get_collider()
				if collider.is_in_group("wall"):  # safer than using name
					direction *= -1
					update_raycast_direction()
			velocity = global_position - previous_position
		else:
			global_position.y += direction * speed * delta
			if global_position.y > start_y + range or global_position.y < start_y:
				direction *= -1  # reverse direction
				if player_on_platform:
					player_on_platform.platform_speed *= -1
				update_raycast_direction()
			if wall_ray.is_colliding():
				var collider = wall_ray.get_collider()
				if collider.is_in_group("wall"):  # safer than using name
					direction *= -1
					update_raycast_direction()
			velocity = global_position - previous_position
	previous_position = global_position  

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		player_on_platform = body
		body.is_on_platform = true
		body.platform_speed = velocity

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		player_on_platform = null
		body.is_on_platform = false
		body.platform_speed = null
		


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
