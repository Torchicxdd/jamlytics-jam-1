extends Object

class_name InputHandler

func get_normalized_keyboard_input_direction():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return input_direction.normalized()

func get_keyboard_input_direction():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return input_direction
