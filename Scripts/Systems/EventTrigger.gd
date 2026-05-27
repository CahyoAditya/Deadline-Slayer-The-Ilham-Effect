extends Node

func _ready() -> void:
	EventBus.progress_threshold_reached.connect(_on_threshold_reached)

func _on_threshold_reached(threshold: int) -> void:
	print("Progress threshold reached: ", threshold)
	match threshold:
		25:
			_fire_event_25()
		50:
			_fire_event_50()
		75:
			_fire_event_75()
		99:
			_fire_kernel_panic()
		100:
			GameManager.trigger_win()

func _fire_event_25() -> void:
	AudioManager.play_sfx("specter_whisper")
	GameManager.is_specter_active = true
	EventBus.emit_specter_spawned()
	EventBus.emit_message_requested("Something started moving in the room.")

func _fire_event_50() -> void:
	EventBus.emit_jumpscare_fired("doorway_jumpscare")
	EventBus.emit_specter_spawned()
	EventBus.emit_message_requested("The doorway is not empty.")

func _fire_event_75() -> void:
	EventBus.emit_jumpscare_fired("desk_jumpscare")
	AudioManager.play_sfx("jumpscare_02")
	EventBus.emit_specter_spawned()
	EventBus.emit_message_requested("The lights hate you now.")

func _fire_kernel_panic() -> void:
	GameManager.set_state(GameManager.GameState.KERNEL_PANIC)
	EventBus.emit_kernel_panic_triggered()
