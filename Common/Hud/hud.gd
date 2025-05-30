extends HBoxContainer

func _ready() -> void:
	Global.hud = self
	
func add_health():
	$VBoxContainer/HealthBar.add_health()
	
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
