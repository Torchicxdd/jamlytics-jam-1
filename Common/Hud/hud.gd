extends VBoxContainer

var is_timer_running = false
var timer: Timer

func _ready() -> void:
	SignalBus.connect("heal_player", Callable(self, "_on_heal_player"))
	SignalBus.connect("death", Callable(self, "_on_death"))
	SignalBus.connect("is_charging", Callable(self, "update_charge_bar"))
	SignalBus.connect("take_damage", Callable(self, "_on_take_damage"))
	SignalBus.connect("start_level_timer", Callable(self, "_on_start_level_timer"))
	SignalBus.connect("stop_level_timer", Callable(self, "_on_stop_level_timer"))
	SignalBus.connect("finished_level", Callable(self, "_on_stop_level_timer"))
	$PanelContainer.visible = false
	
func _process(delta: float) -> void:
	if is_timer_running and timer:
		$PanelContainer/HBoxContainer/Timer.text = "%s" % ceil(timer.time_left)
	
func _on_heal_player(amount: int):
	for i in amount:
		$HBoxContainer2/VBoxContainer/HealthBar.add_health()
	
func _on_death():
	clear_health_bars()
	reset_charge_bar()
	
func _on_take_damage(amount: int):
	for i in amount:
		var last_bar = $HBoxContainer2/VBoxContainer/HealthBar.get_child($HBoxContainer2/VBoxContainer/HealthBar.get_child_count()- (i+1))
		last_bar.queue_free()
	
func _on_start_level_timer(current_timer: Timer):
	is_timer_running = true
	timer = current_timer
	$PanelContainer.visible = true
	
func _on_stop_level_timer():
	is_timer_running = false
	$PanelContainer.visible = false
	
func clear_health_bars():
	for bar in $HBoxContainer2/VBoxContainer/HealthBar.get_children():
		bar.queue_free()

func update_health_bars(health: int):
	for bar in range($HBoxContainer2/VBoxContainer/HealthBar.get_child_count()):
		$HBoxContainer2/VBoxContainer/HealthBar.get_child(bar).visible = bar < health

func reset_charge_bar():
	$HBoxContainer2/VBoxContainer/ChargeBar.value = 0.0

func update_charge_bar(current_charge_time: float, max_charge_time: float):
	$HBoxContainer2/VBoxContainer/ChargeBar.value = current_charge_time / max_charge_time
