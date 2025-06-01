extends CanvasLayer

@export_file("*.json") var scene_text_file: String

var scene_text: Dictionary = {}
var selected_text: Array = []

@onready var background = $Background
@onready var text_label = $TextLabel

var input_map_values: Array = InputMap.get_actions()

func _ready() -> void:
	background.visible = false
	scene_text = load_scene_text()
	SignalBus.connect("display_dialog", Callable(self, "on_display_dialog"))	
	SignalBus.connect("advance_dialog", Callable(self, "on_advance_dialog"))

func load_scene_text():
	if FileAccess.file_exists(scene_text_file):
		var file = FileAccess.open(scene_text_file, FileAccess.READ)
		var json = JSON.new()
		json.parse(file.get_as_text())
		return json.data
		
func on_advance_dialog():
	next_line()

func on_display_dialog(text_key):
	get_tree().paused = true
	background.visible = true
	selected_text = scene_text[text_key].duplicate()
	show_text()
		
func show_text():
	text_label.text = replace_variables(selected_text.pop_front())
	
func next_line():
	if selected_text.size() > 0:
		show_text()
	else:
		finish()
		SignalBus.emit_signal("dialog_finished")
		
func finish():
	text_label.text = ""
	background.visible = false
	get_tree().paused = false
	
func replace_variables(text: String) -> String:
	var pattern = RegEx.new()
	pattern.compile(r"\{(\w+)\}")
	var result = text
	for match in pattern.search_all(text):
		var key_brackets = match.get_string()
		var key = key_brackets.substr(1, key_brackets.length() - 2)
		var value_pos = input_map_values.find(key)
		if value_pos != -1:
			var action = input_map_values[value_pos]
			var action_key = InputMap.action_get_events(action)
			var keycode = action_key[0].physical_keycode
			var key_name = OS.get_keycode_string(keycode)
			result = result.replace("{" + key + "}", key_name)
	
	return result
