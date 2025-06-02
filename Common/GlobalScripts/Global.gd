extends Node

func _ready() -> void:
	SignalBus.connect("game_end", Callable(self, "_on_game_end"))

var world
var loaded_levels: Array = []

func _on_game_end():
	get_tree().change_scene_to_file("res://Stages/Ending/EndingScene.tscn")
