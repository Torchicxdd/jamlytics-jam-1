extends Node

# Dialog signals
signal display_dialog(text_key: String)
signal advance_dialog()
signal dialog_finished()

# Player
signal death()
signal set_checkpoint(location: Vector2)
signal heal_player(amount: int)
signal is_swinging()
signal has_stopped_swinging()
signal is_charging(current_charge_time: float, max_charge_time: float)
signal take_damage(amount: int)
signal on_platform(speed: Vector2)
signal off_platform()

# Socket
signal swinging()

# Timer
signal start_level_timer(timer: Timer)
signal stop_level_timer()
signal finished_level()
