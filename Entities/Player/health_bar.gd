extends HBoxContainer

var health_value = preload("res://Assets/Hud/health_value.tscn")

func add_health():
	var health = health_value.instantiate()
	add_child(health)
