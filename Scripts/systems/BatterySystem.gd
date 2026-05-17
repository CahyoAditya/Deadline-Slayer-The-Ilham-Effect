extends Node

var battery_level: float = 100.0
var flashlight_on: bool = true
const DRAIN_RATE: float = 1.0 # % per second when on

func _process(delta: float) -> void:
	if flashlight_on and GameManager.current_state == GameManager.GameState.PLAYING:
		battery_level = clamp(battery_level - DRAIN_RATE * delta, 0.0, 100.0)
		EventBus.battery_changed.emit(battery_level)
		if battery_level <= 0.0:
			flashlight_on = false
			EventBus.battery_depleted.emit()
