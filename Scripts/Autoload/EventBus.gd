extends Node

signal game_state_changed(new_state: int)
signal deadline_changed(time_left_seconds: float)
signal game_won()
signal game_lost(reason: String)

signal global_timer_started(duration_seconds: float)
signal global_timer_tick(time_left_seconds: float)
signal five_minutes_elapsed()
signal global_timer_finished()

signal progress_changed(new_percent: float)
signal progress_threshold_reached(threshold: int)

signal sanity_changed(new_value: float)
signal sanity_critical()
signal sanity_depleted()

signal battery_changed(new_value: float)
signal battery_depleted()
signal flashlight_toggled(is_on: bool)

signal specter_spawned()
signal specter_sight_broken()
signal specter_sight_maintained()
signal specter_caught_player()

signal game_paused()
signal game_resumed()
signal kernel_panic_triggered()
signal kernel_panic_resolved()
signal jumpscare_fired(jumpscare_id: String)

signal interact_hint_changed(text: String)
signal terminal_requested()
signal terminal_opened()
signal terminal_closed()
signal message_requested(text: String)

func emit_game_state_changed(new_state: int) -> void:
	game_state_changed.emit(new_state)

func emit_deadline_changed(time_left_seconds: float) -> void:
	deadline_changed.emit(time_left_seconds)

func emit_game_won() -> void:
	game_won.emit()

func emit_game_lost(reason: String) -> void:
	game_lost.emit(reason)

func emit_global_timer_started(duration_seconds: float) -> void:
	global_timer_started.emit(duration_seconds)

func emit_global_timer_tick(time_left_seconds: float) -> void:
	global_timer_tick.emit(time_left_seconds)

func emit_five_minutes_elapsed() -> void:
	five_minutes_elapsed.emit()
	global_timer_finished.emit()

func emit_progress_changed(new_percent: float) -> void:
	progress_changed.emit(new_percent)

func emit_progress_threshold_reached(threshold: int) -> void:
	progress_threshold_reached.emit(threshold)

func emit_sanity_changed(new_value: float) -> void:
	sanity_changed.emit(new_value)

func emit_sanity_critical() -> void:
	sanity_critical.emit()

func emit_sanity_depleted() -> void:
	sanity_depleted.emit()

func emit_battery_changed(new_value: float) -> void:
	battery_changed.emit(new_value)

func emit_battery_depleted() -> void:
	battery_depleted.emit()

func emit_flashlight_toggled(is_on: bool) -> void:
	flashlight_toggled.emit(is_on)

func emit_specter_spawned() -> void:
	specter_spawned.emit()

func emit_specter_sight_broken() -> void:
	specter_sight_broken.emit()

func emit_specter_sight_maintained() -> void:
	specter_sight_maintained.emit()

func emit_specter_caught_player() -> void:
	specter_caught_player.emit()

func emit_game_paused() -> void:
	game_paused.emit()

func emit_game_resumed() -> void:
	game_resumed.emit()

func emit_kernel_panic_triggered() -> void:
	kernel_panic_triggered.emit()

func emit_kernel_panic_resolved() -> void:
	kernel_panic_resolved.emit()

func emit_jumpscare_fired(jumpscare_id: String) -> void:
	jumpscare_fired.emit(jumpscare_id)

func emit_interact_hint_changed(text: String) -> void:
	interact_hint_changed.emit(text)

func emit_terminal_requested() -> void:
	terminal_requested.emit()

func emit_terminal_opened() -> void:
	terminal_opened.emit()

func emit_terminal_closed() -> void:
	terminal_closed.emit()

func emit_message_requested(text: String) -> void:
	message_requested.emit(text)
