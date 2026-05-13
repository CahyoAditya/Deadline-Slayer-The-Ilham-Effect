extends Node

@warning_ignore_start("unused_signal")

signal progress_changed(new_percent: float)
signal progress_threshold_reached(threshold: int)

signal sanity_changed(new_value: float)
signal sanity_critical()
signal sanity_depleted()

signal battery_changed(new_value: float)
signal battery_depleted()

signal specter_spawned()
signal specter_sight_broken()
signal specter_sight_maintained()
signal specter_caught_player()

signal game_paused()
signal game_resumed()
signal kernel_panic_triggered()
signal kernel_panic_resolved()
signal jumpscare_fired(jumpscare_id: String)

@warning_ignore_restore("unused_signal")
