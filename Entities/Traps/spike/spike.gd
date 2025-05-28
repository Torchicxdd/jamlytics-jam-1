extends Area2D
@onready var wall_ray := $WallRay
@export var damage := 1
@export var is_moving := false
@export var move_distance := 100.0
@export var speed := 100.0
@export var range := 500.0
@export var horizontal := true

var direction := 1
var start_x := 0.0
var start_y := 0.0

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
				update_raycast_direction()
			if wall_ray.is_colliding():
				var collider = wall_ray.get_collider()
				if collider.is_in_group("wall"):  # safer than using name
					direction *= -1
					update_raycast_direction()
		else:
			global_position.y += direction * speed * delta
			if global_position.y > start_y + range or global_position.y < start_y:
				direction *= -1  # reverse direction
				update_raycast_direction()
			if wall_ray.is_colliding():
				var collider = wall_ray.get_collider()
				if collider.is_in_group("wall"):  # safer than using name
					direction *= -1
					update_raycast_direction()
