extends HBoxContainer

func _ready() -> void:
	SignalBus.connect("heal_player", Callable(self, "_on_heal_player"))
	SignalBus.connect("death", Callable(self, "_on_death"))
	SignalBus.connect("is_charging", Callable(self, "update_charge_bar"))
	SignalBus.connect("take_damage", Callable(self, "_on_take_damage"))
	
func _on_heal_player(amount: int):
	for i in amount:
		$VBoxContainer/HealthBar.add_health()
	
func _on_death():
	clear_health_bars()
	reset_charge_bar()
	
func _on_take_damage(amount: int):
	for i in amount:
		var last_bar = $VBoxContainer/HealthBar.get_child($VBoxContainer/HealthBar.get_child_count()- (i+1))
		last_bar.queue_free()
	
func clear_health_bars():
	for bar in $VBoxContainer/HealthBar.get_children():
		bar.queue_free()

func update_health_bars(health: int):
	for bar in range($VBoxContainer/HealthBar.get_child_count()):
		$VBoxContainer/HealthBar.get_child(bar).visible = bar < health

func reset_charge_bar():
	$VBoxContainer/ChargeBar.value = 0.0

func update_charge_bar(current_charge_time: float, max_charge_time: float):
	$VBoxContainer/ChargeBar.value = current_charge_time / max_charge_time
