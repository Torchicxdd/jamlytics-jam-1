extends Control

@onready var audio_name = $HBoxContainer/audio_name as Label
@onready var audio_num = $HBoxContainer/audio_num as Label
@onready var slider = $HBoxContainer/HSlider as HSlider

@export_enum("Master", "Music", "Sfx") var bus_name : String

var bus_index : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	slider.value_changed.connect(on_value_changed)
	get_bus_name_by_index()
	set_audio_name_label_text()
	set_slider_value()


func set_audio_name_label_text() -> void:
	audio_name.text = str(bus_name) + " Volume"
	
func set_audio_num_text() -> void:
	audio_num.text = str(slider.value * 100)
	
func set_slider_value() -> void:
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	set_audio_name_label_text()

func on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	set_audio_num_text()

func get_bus_name_by_index() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
