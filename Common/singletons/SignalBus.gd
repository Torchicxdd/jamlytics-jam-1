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

# Socket
signal swinging()
