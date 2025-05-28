class_name Socket extends Node2D

var is_hookable = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	is_hookable = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	is_hookable = false
