extends Node

var current_progress := 0.0
var thresholds_fired: Array[int] = []

func _ready() -> void:
	reset()

func reset() -> void:
	current_progress = 0.0
	thresholds_fired.clear()
	EventBus.emit_progress_changed(current_progress)

func add_progress(amount: float) -> void:
	if amount <= 0.0 or not GameManager.is_playing():
		return

	current_progress = clamp(current_progress + amount, 0.0, GameManager.progress_data.max_progress)
	GameManager.progress_data.current_progress = current_progress
	EventBus.emit_progress_changed(current_progress)
	_check_thresholds()

func get_progress() -> float:
	return current_progress

func _check_thresholds() -> void:
	for threshold in GameManager.event_config.thresholds:
		if current_progress >= float(threshold) and threshold not in thresholds_fired:
			thresholds_fired.append(threshold)
			EventBus.emit_progress_threshold_reached(threshold)
			if threshold == 99:
				break
