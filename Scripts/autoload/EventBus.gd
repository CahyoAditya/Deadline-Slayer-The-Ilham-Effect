extends Node

# Progress events
signal progress_changed(new_percent: float)
signal progress_threshold_reached(threshold: int)

# Sanity events
signal sanity_changed(new_value: float)
signal sanity_critical()
signal sanity_depleted()

# Battery events
signal battery_changed(new_value: float)
signal battery_depleted()

# Specter events
signal specter_spawned()
signal specter_sight_broken()
signal specter_sight_maintained()
signal specter_caught_player()

# Game state events
signal game_paused()
signal game_resumed()
signal kernel_panic_triggered()
signal kernel_panic_resolved()
signal jumpscare_fired(jumpscare_id: String)
