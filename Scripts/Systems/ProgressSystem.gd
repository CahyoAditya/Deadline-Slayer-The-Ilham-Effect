extends Node

@export var current_progress: float = 0.0
@export var thresholds: Array[int] = [25, 50, 75, 99, 100]

var thresholds_fired: Array[int] = []

func _ready() -> void:
	current_progress = clamp(current_progress, 0.0, 100.0)
	_event_bus().progress_changed.emit(current_progress)

func add_progress(amount: float) -> void:
	if amount <= 0.0:
		return

	current_progress = clamp(current_progress + amount, 0.0, 100.0)
	_event_bus().progress_changed.emit(current_progress)
	_check_thresholds()

func reset() -> void:
	current_progress = 0.0
	thresholds_fired.clear()
	_event_bus().progress_changed.emit(current_progress)

func _check_thresholds() -> void:
	for threshold in thresholds:
		if current_progress >= threshold and threshold not in thresholds_fired:
			thresholds_fired.append(threshold)
			_event_bus().progress_threshold_reached.emit(threshold)
			print("Progress threshold reached: ", threshold, "%")

func _event_bus():
	return get_node("/root/EventBus")
