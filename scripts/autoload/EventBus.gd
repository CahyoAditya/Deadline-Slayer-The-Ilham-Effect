extends Node

# Progress events
signal progress_changed(new_percent: float)
signal progress_threshold_reached(threshold: int)  # 25, 50, 75, 99, 100

# Sanity events
signal sanity_changed(new_value: float)
signal sanity_critical()          # < 20%
signal sanity_depleted()          # = 0 -> lose condition

# Battery events
signal battery_changed(new_value: float)
signal battery_depleted()         # Flashlight off

# Specter events
signal specter_spawned()
signal specter_sight_broken()     # Player looks away
signal specter_sight_maintained() # Player maintains eye contact
signal specter_caught_player()    # Lose condition

# Game state events
signal game_paused()
signal game_resumed()
signal kernel_panic_triggered()
signal kernel_panic_resolved()
signal jumpscare_fired(jumpscare_id: String)
