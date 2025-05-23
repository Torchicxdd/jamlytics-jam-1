extends Area2D

@export var damage := 1
@export var is_moving := false
@export var move_distance := 100.0
@export var speed := 100.0
@export var range := 200.0
@export var horizontal := true

var direction := 1
var start_x := 0.0
var start_y := 0.0

func _ready():
	start_x = global_position.x
	start_y = global_position.y

func _process(delta):
	if is_moving:
		if horizontal:
			global_position.x += direction * speed * delta
			if abs(global_position.x - start_x) >= range:
				direction *= -1  # reverse direction
		else:
			global_position.y += direction * speed * delta
			if abs(global_position.y - start_y) >= range:
				direction *= -1  # reverse direction

func player_hit(body):
	if body.name == "Player":
		body.respawn()
